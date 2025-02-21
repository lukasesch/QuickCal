//
//  CameraManager.swift
//  QuickCal
//
//  Created by Lukas Esch on 05.12.24.
//

import UIKit
import AVFoundation

// Delegate: Fehler melden
protocol CameraManagerDelegate: AnyObject {
    func didDetectBarcode(with code: String)
    func didFail(with error: Error)
}

final class CameraManager: NSObject {
    
    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let sessionQueue = DispatchQueue(label: "com.quickcal.cameraSession")  // Serielle Queue
    weak var delegate: CameraManagerDelegate?
    
    // Session konfigurieren
    func configureSession(in view: UIView) {
        checkCameraPermissions { [weak self] granted in
            guard let self = self else { return }
            if granted {
                // serielle Session Queue
                self.sessionQueue.async {
                    self.setupSession()  // beginConfiguration und commitConfiguration Funktionen
                    self.captureSession.startRunning()
                    // UI-Updates Main Thread
                    DispatchQueue.main.async {
                        self.setupPreviewLayer(in: view)
                    }
                }
            } else {
                let error = NSError(domain: "CameraManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Kamerazugriff verweigert"])
                DispatchQueue.main.async {
                    self.delegate?.didFail(with: error)
                }
            }
        }
    }
    
    // Session auf Session Queue starten
    func startSession() {
        if !captureSession.isRunning {
            sessionQueue.async {
                self.captureSession.startRunning()
            }
        }
    }
    
    // Session stoppen
    func stopSession() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    
    // Session zurücksetzen, stoppen, Outputs und Preview Layer entfernen
    func resetSession() {
        captureSession.stopRunning()
        for input in captureSession.inputs {
            captureSession.removeInput(input)
        }
        for output in captureSession.outputs {
            captureSession.removeOutput(output)
        }
        previewLayer?.removeFromSuperlayer()
        previewLayer = nil
    }
    
    // PreviewLayer für UI zurückgeben
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        return previewLayer
    }
    
    // Neu: Taschenlampe an/aus
    func toggleTorch() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = (device.torchMode == .off) ? .on : .off
            device.unlockForConfiguration()
        } catch {
            delegate?.didFail(with: error)
        }
    }
    
    
    // Kamera Session konfigurieren + Meta Output (Barcode Erkennung)
    private func setupSession() {
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }
        
        // Auswahl der Rückkamera
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            let error = NSError(domain: "CameraManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Keine Rückkamera gefunden"])
            delegate?.didFail(with: error)
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
        } catch {
            delegate?.didFail(with: error)
            return
        }
        
        // Metadata-Outputs für die Barcode Erkennung
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            // BarCode Typen
            metadataOutput.metadataObjectTypes = [.ean13, .ean8, .code128, .qr]
        } else {
            let error = NSError(domain: "CameraManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "Kann Metadata-Output nicht hinzufügen"])
            delegate?.didFail(with: error)
            return
        }
    }
    
    // Preview Layer Setup
    private func setupPreviewLayer(in view: UIView) {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.bounds
        if let layer = previewLayer {
            view.layer.insertSublayer(layer, at: 0)
        }
    }
    
    // Kamera Zugriff
    private func checkCameraPermissions(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: completion)
        default:
            completion(false)
        }
    }
}


extension CameraManager: AVCaptureMetadataOutputObjectsDelegate {
    
    // BarCode erkannt? Dann diese Methode
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let metadataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let code = metadataObj.stringValue else { return }
        delegate?.didDetectBarcode(with: code)
    }
}
