//
//  CameraManager.swift
//  QuickCal
//
//  Created by Lukas Esch on 05.12.24.
//

import Foundation
import AVFoundation
import Combine

class CameraManager: NSObject, ObservableObject {
    // Kamera Session
    private let session = AVCaptureSession()
    // Nebenlaeufige Queue damit UI nicht blockiert wird
    private let sessionQueue = DispatchQueue(label: "cameraSessionQueue")
    // Video Device aka Kamera
    private var videoDevice: AVCaptureDevice?
    // Output der Camera, Barcodes, ...
    private let metadataOutput = AVCaptureMetadataOutput()
    // Combine Subscriptions, sodass ViewModel automatisch Daten beziehen kann
    private var cancellables = Set<AnyCancellable>() // Combine-Subscriptions
    // Erkannte Barcodes
    @Published var scannedCode: String?
    
    func configureSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.session.beginConfiguration()
            //Lookup defer
            defer { self.session.commitConfiguration() }
            
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
                  self.session.canAddInput(videoInput) else {
                print("Error: VideoInput konnte nicht hinzugefügt werden.")
                return
            }
            self.session.addInput(videoInput)
            self.videoDevice = videoDevice
            
            //MetaData Output
            guard self.session.canAddOutput(self.metadataOutput) else {
                print("Error: Could not add metadata output.")
                return
            }
            self.session.addOutput(self.metadataOutput)
            
            // MetaData auf nebenlauefigem Thread und auf ean13 festlegen
            self.metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            self.metadataOutput.metadataObjectTypes = [.ean13, .ean8]

        }
        
        // Starten der Session
        func startSession() {
            sessionQueue.async { [weak self] in
                guard let self = self else { return }
                if !self.session.isRunning {
                    self.session.startRunning()
                }
            }
        }
        
        // Stoppen der Session
        func stopSession() {
            sessionQueue.async { [weak self] in
                guard let self = self else { return }
                if self.session.isRunning {
                    self.session.stopRunning()
                }
            }
        }
        
    }
}

// Extension fuer Combine, sodass die Barcodes via Published veroeffentlicht werden
extension CameraManager: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = metadataObject.stringValue else { return }
        
        DispatchQueue.main.async {
            self.scannedCode = stringValue // Veröffentlicht den Barcode
        }
    }
}
