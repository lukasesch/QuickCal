//
//  BarCodeView.swift
//  QuickCal
//
//  Created by Lukas Esch on 25.10.24.
//

import SwiftUI
import AVFoundation

struct BarCodeView: View {
    @EnvironmentObject var barCodeViewModel: BarCodeViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isConfiguring = true

    
    var body: some View {
        NavigationStack {
            VStack {
                if isConfiguring {
                    Text("Kamera wird vorbereitet...")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                } else if barCodeViewModel.isSessionRunning {
                    CameraPreviewView(previewLayer: barCodeViewModel.getPreviewLayer())
                        .edgesIgnoringSafeArea(.all)
                } else {
                    Text("Kamera konnte nicht gestartet werden.")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .onAppear {
                configureCamera()
            }
            .onDisappear {
                barCodeViewModel.stopScanning()
            }
        }
    }
    
    // Delay needed, otherwise camera initializes with black screen
    func configureCamera() {
        barCodeViewModel.startScanning()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isConfiguring = false
        }
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer) // Add Preview to View
        print("makeUIView aufgerufen")
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            self.previewLayer.frame = uiView.bounds
            if let connection = self.previewLayer.connection, !connection.isEnabled {
                connection.isEnabled = true
                print("PreviewLayer aktiviert.")
            } else if self.previewLayer.connection == nil {
                print("Keine Verbindung zum PreviewLayer vorhanden.")
            }
        }
    }
}


#Preview {
    BarCodeView()
        .environmentObject(BarCodeViewModel())
}
