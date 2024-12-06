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
    @EnvironmentObject var mainViewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var isConfiguring = true
    
    // Alert
    @State private var showCustomAlert = false
    @State private var selectedFood: FoodItem?
    @State private var quantity: String = ""
    
    var selectedDaytime: Int
    
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
            .onChange(of: barCodeViewModel.scannedBarcode) {
                if let barcode = barCodeViewModel.scannedBarcode {
                    barCodeViewModel.searchProductByBarcode(barcode: barcode) { foodItem in
                        if let item = foodItem {
                            selectedFood = item
                            showCustomAlert = true
                        } else {
                            print("Kein Produkt gefunden.")
                        }
                    }
                }
            }
        }
        .overlay(
            Group {
                if showCustomAlert {
                    CustomAlertOFF(
                        isPresented: $showCustomAlert,
                        quantity: $quantity,
                        foodItem: selectedFood, // Übergib das ausgewählte FoodItem
                        onSave: {
                            if let food = selectedFood, let quantityValue = Float(quantity.replacingOccurrences(of: ",", with: ".")) {
                                barCodeViewModel.OpenFoodFactsFoodToDB(name: selectedFood?.name ?? "", defaultQuantity: selectedFood?.defaultQuantity ?? 0, unit: selectedFood?.unit ?? "g", calories: selectedFood?.kcal ?? 0, carbs: selectedFood?.carbohydrate ?? 0, protein: selectedFood?.protein ?? 0, fat: selectedFood?.fat ?? 0, daytime: Int16(selectedDaytime), quantity: quantityValue)
                                print("FoodItem \(food.name) mit Menge \(quantityValue) hinzugefügt!")
                                mainViewModel.updateData()
                                resetAlert()
                                dismiss()
                            }
                        },
                        onCancel: {
                            resetAlert()
                            dismiss()
                        }
                    )
                    .transition(.opacity)
                }
            }
        )
        .animation(.easeInOut(duration: 0.2), value: showCustomAlert)
    }
    
    // Delay needed, otherwise camera initializes with black screen
    func configureCamera() {
        barCodeViewModel.startScanning()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            isConfiguring = false
        }
    }
    
    private func resetAlert() {
        withAnimation {
            showCustomAlert = false
        }
        selectedFood = nil
        quantity = ""
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
                //print("Keine Verbindung zum PreviewLayer vorhanden.")
            }
        }
    }
}


#Preview {
    let context = PersistenceController.preview.container.viewContext
    BarCodeView(selectedDaytime: 0)
        .environmentObject(BarCodeViewModel(context: context))
}
