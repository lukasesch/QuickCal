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
    
    private var isStartingSession = false
    
    
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
            
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                print("Kein passendes Kameragerät gefunden.")
                completion(false)
                return
            }
            
            // Prüfe, ob die Session schon einen Input hat
            if !self.session.inputs.isEmpty {
                print("Session hat bereits Inputs: \(self.session.inputs)")
                DispatchQueue.main.async {
                    self.isSessionConfigured = true
                    if self.previewLayer == nil {
                        let newLayer = AVCaptureVideoPreviewLayer(session: self.session)
                        newLayer.videoGravity = .resizeAspectFill
                        self.previewLayer = newLayer
                    }
                    completion(true)
                }
                return
            }
            
            do {
                let videoInput = try AVCaptureDeviceInput(device: videoDevice)
                if self.session.canAddInput(videoInput) {
                    self.session.addInput(videoInput)
                } else {
                    print("Session kann den Kamera-Input nicht hinzufügen.")
                    completion(false)
                    return
                }
            } catch {
                print("Fehler beim Erstellen des Kamera-Inputs: \(error.localizedDescription)")
                completion(false)
                return
            }
            
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
                //print("Kamera konfiguriert")
            }
        }
    }
    
    func startSession() {
        sessionQueue.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            // Wenn bereits ein Start-Versuch läuft oder die Session läuft, abbrechen
            guard !self.isStartingSession, !self.session.isRunning else {
                print("Meep")
                return
            }
            self.isStartingSession = true
            self.session.startRunning()
            print("Session gestartet.")
            self.isStartingSession = false
        }
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
                print("Session gestoppt.")
            }
            // Optionalen Preview Layer ggf entfernen
            DispatchQueue.main.async {
                self.previewLayer?.removeFromSuperlayer()
                self.previewLayer = nil
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
            
            // Entferne den Preview-Layer, falls er existiert
            DispatchQueue.main.async {
                self.previewLayer?.removeFromSuperlayer()
                self.previewLayer = nil
                print("Session und Preview-Layer zurückgesetzt.")
            }
        }
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
        if let existingLayer = previewLayer {
            return existingLayer
        } else {
            let newLayer = AVCaptureVideoPreviewLayer(session: session)
            newLayer.videoGravity = .resizeAspectFill
            previewLayer = newLayer
            return newLayer
        }
    }
    
    func isSessionRunning() -> Bool {
        return session.isRunning
    }
    
    func pauseSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
                print("Session pausiert.")
            }
        }
    }
}


// Extentension for Combine Framework to publish Data to ViewModel
extension CameraManager: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = metadataObject.stringValue else { return }
        
        DispatchQueue.main.async {
            self.scannedCode = stringValue // Publishes BarCode
            self.pauseSession()  
            
        }
    }
}
