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
                } else {
                    CameraPreviewView { view in
                        print("CameraPreviewView: UIView erstellt – starte Scanning")
                        barCodeViewModel.startScanning(in: view)
                    }
                    .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        Spacer()
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 300, height: 180)
                            Text("Barcode")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding(.bottom, 100)
                        Spacer()
                    }
                }

                // Abbruch Button
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            barCodeViewModel.stopScanning()
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.title)
                                .frame(width: 50, height: 50) // Feste Größe
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                                .foregroundColor(.white)
                        }
                        .padding(.trailing, 35.0)
                    }
                    Spacer()
                }
                
                // Taschenlampen
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            barCodeViewModel.toggleTorch()
                        }) {
                            Image(systemName: "flashlight.on.fill")
                                .font(.title)
                                .frame(width: 50, height: 50) // Gleiche feste Größe
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                                .foregroundColor(.white)
                        }
                        .padding(.trailing, 35.0)
                    }
                }
            }
            .onAppear {
                checkCameraAuthorization { granted in
                    if granted {
                        print("Kamerazugriff erteilt.")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isConfiguring = false
                        }
                    } else {
                        print("Kamerazugriff verweigert.")
                    }
                }
            }
            // Barcode gescannt und Object auf OpenFoodFacts gefunden? Dann anzeigen:
            .onChange(of: barCodeViewModel.product?.id) { newID, oldID in
                if let product = barCodeViewModel.product {
                    selectedFood = product
                    showCustomAlert = true
                }
            }
            .navigationBarHidden(true)
        }
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { gesture in
                    if gesture.translation.height > 50 {
                        barCodeViewModel.stopScanning()
                        dismiss()
                    }
                }
        )
        .overlay(
            Group {
                if showCustomAlert {
                    CustomAlertOFF(
                        isPresented: $showCustomAlert,
                        quantity: $quantity,
                        foodItem: selectedFood,
                        onSave: {
                            if let food = selectedFood,
                               let quantityValue = Float(quantity.replacingOccurrences(of: ",", with: ".")) {
                                barCodeViewModel.OpenFoodFactsFoodToDB(
                                    name: food.name,
                                    defaultQuantity: food.defaultQuantity,
                                    unit: food.unit,
                                    calories: food.kcal,
                                    carbs: food.carbohydrate,
                                    protein: food.protein,
                                    fat: food.fat,
                                    daytime: Int16(selectedDaytime),
                                    quantity: quantityValue,
                                    selectedDate: selectedDate
                                )
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
    var onViewCreated: ((UIView) -> Void)? = nil
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        onViewCreated?(view)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Kein Update notwendig
    }
}


#Preview {
    let context = PersistenceController.preview.container.viewContext
    BarCodeView(selectedDaytime: 0, selectedDate: Date())
        .environmentObject(BarCodeViewModel(context: context))
}
