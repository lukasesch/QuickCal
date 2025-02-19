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
    @EnvironmentObject var addTrackedFoodViewModel: AddTrackedFoodViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var isConfiguring = true
    
    // Alert
    @State private var showCustomAlert = false
    @State private var selectedFood: FoodItem?
    @State private var quantity: String = ""
    
    var selectedDaytime: Int
    var selectedDate: Date
    
    var body: some View {
        NavigationStack {
            ZStack {
                if isConfiguring {
                    Text("Kamera wird vorbereitet...")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                } else if barCodeViewModel.isSessionRunning {
                    CameraPreviewView(previewLayer: barCodeViewModel.getPreviewLayer())
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        Spacer()
                        
                        // Fester Bereich für den Barcode-Scan
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white, lineWidth: 4) // Weißer Rahmen
                                .frame(width: 300, height: 180) // Größe des Scanbereichs
                            
                            VStack {
                                Spacer()
                                Spacer()
                                Text("Barcode")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.top, 20)
                                Spacer()
                            }
                        }
                        .padding(.bottom, 100) // Abstand nach unten, damit es nicht ganz in der Mitte ist
                        
                        Spacer()
                    }
                } else {
                    Text("Kamera wird vorbereitet...")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                }
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            barCodeViewModel.pauseScanning()
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.title)
                                .padding()
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                                .foregroundColor(.white)
                        }
                        .padding()
                    }
                    Spacer()
                }
            }
            .onAppear {
                checkCameraAuthorization { granted in
                    if granted {
                        print("Kamerazugriff erteilt.")
                        barCodeViewModel.startScanning()
                        configureCamera()
                    } else {
                        print("Kamerazugriff verweigert.")
                        // Hier kannst du ggf. eine Fehlermeldung anzeigen oder andere Maßnahmen ergreifen.
                    }
                }
            }
            .onDisappear {
                
            }
            .onChange(of: barCodeViewModel.scannedBarcode) {
                if let barcode = barCodeViewModel.scannedBarcode {
                    barCodeViewModel.scannedBarcode = nil
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
            .navigationBarHidden(true)
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
                                barCodeViewModel.OpenFoodFactsFoodToDB(name: selectedFood?.name ?? "", defaultQuantity: selectedFood?.defaultQuantity ?? 0, unit: selectedFood?.unit ?? "g", calories: selectedFood?.kcal ?? 0, carbs: selectedFood?.carbohydrate ?? 0, protein: selectedFood?.protein ?? 0, fat: selectedFood?.fat ?? 0, daytime: Int16(selectedDaytime), quantity: quantityValue, selectedDate: selectedDate)
                                print("FoodItem \(food.name) mit Menge \(quantityValue) hinzugefügt!")
                                mainViewModel.updateData()
                                addTrackedFoodViewModel.fetchFoodItems()
                                addTrackedFoodViewModel.fetchMealItems()
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
        DispatchQueue.main.asyncAfter(deadline: .now()) {
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
    
    private func checkCameraAuthorization(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        default:
            completion(false)
        }
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        
        // Entferne den Preview-Layer aus einem möglichen alten Superlayer
        previewLayer.removeFromSuperlayer()
        previewLayer.frame = view.bounds
        
        // Füge den Preview-Layer der neuen View hinzu
        view.layer.addSublayer(previewLayer)
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
    BarCodeView(selectedDaytime: 0, selectedDate: Date())
        .environmentObject(BarCodeViewModel(context: context))
}
