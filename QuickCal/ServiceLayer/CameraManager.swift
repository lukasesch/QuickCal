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
    // Camera Session
    private var session = AVCaptureSession()
    // Concurrent Thread
    private let sessionQueue = DispatchQueue(label: "cameraSessionQueue")
    // Output of Camera Session
    private let metadataOutput = AVCaptureMetadataOutput()
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    // Scanned Barcode published to ViewModel
    @Published var scannedCode: String?
    // Session configured?
    @Published var isSessionConfigured: Bool = false
    
    
    // Create Session Configuration (camera type, barcode type, ...)
    func configureSession(barcodeTypes: [AVMetadataObject.ObjectType] = [.ean13, .ean8], completion: @escaping (Bool) -> Void) {
        guard !isSessionConfigured else {
            completion(true)
            return
        }
        
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.session.beginConfiguration()
            defer { self.session.commitConfiguration() }
            
            // Config camera type
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
                  session.canAddInput(videoInput) else {
                print("Kamera-Input konnte nicht hinzugefügt werden.")
                completion(false)
                return
            }
            session.addInput(videoInput)
            
            // Config output
            if session.canAddOutput(metadataOutput) {
                session.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.ean13, .ean8]
            } else {
                print("Metadata-Output konnte nicht hinzugefügt werden.")
                completion(false)
                return
            }
            
            DispatchQueue.main.async {
                self.isSessionConfigured = true
                completion(true)
                print("Kamera konfiguriert")
            }
        }
    }
    
    func startSession() {
        sessionQueue.async { [weak self] in
            guard let self = self, !self.session.isRunning else { return }
            self.session.startRunning()
            print("Session running: \(session.isRunning)")
        }
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
                print("Session gestoppt.")
            }
        }
    }
    
    func resetSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.session.stopRunning()
            self.session.inputs.forEach { self.session.removeInput($0) }
            self.session.outputs.forEach { self.session.removeOutput($0) }
            self.isSessionConfigured = false
        }
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        print("Preview Layer zurückgegeben")
        return previewLayer
    }
}


// Extentension for Combine Framework to publish Data to ViewModel
extension CameraManager: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = metadataObject.stringValue else { return }
        
        DispatchQueue.main.async {
            self.scannedCode = stringValue // Publishes BarCode
            self.stopSession()
        }
    }
}
