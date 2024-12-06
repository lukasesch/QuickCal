//
//  BarCodeViewModel.swift
//  QuickCal
//
//  Created by Lukas Esch on 05.12.24.
//

import Foundation
import Combine
import SwiftUI
import AVFoundation

class BarCodeViewModel: ObservableObject {
    @Published var scannedBarcode: String? = nil
    @Published var isSessionRunning: Bool = false
    
    private let cameraManager = CameraManager()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Observe CameraManager Output for scanned Barcode
        cameraManager.$scannedCode
            .compactMap { $0 }  // Ignore Nil Values
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sink { [weak self] barcode in
                DispatchQueue.main.async {
                    self?.scannedBarcode = barcode
                    print("Erkannter Barcode im ViewModel: \(barcode)")
                }
            }
            .store(in: &cancellables)
    }
    
    func startScanning() {
        cameraManager.configureSession { [weak self] success in
            guard success else {
                print("Kamera-Konfiguration fehlgeschlagen.")
                return
            }
            self?.cameraManager.startSession()
            DispatchQueue.main.async {
                self?.isSessionRunning = true
            }
        }
    }
    
    func stopScanning() {
        cameraManager.stopSession()
        isSessionRunning = false
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
        return cameraManager.getPreviewLayer()
    }
    
    func clearPreviewLayer() {
        cameraManager.resetSession()
        isSessionRunning = false
    }
}
