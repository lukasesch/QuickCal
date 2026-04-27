//
//  BarCodeView.swift
//  QuickCal
//
//  Created by Lukas Esch on 25.10.24.
//

import SwiftUI
import AVFoundation

// MARK: - Main view

struct BarCodeView: View {
    @EnvironmentObject var barCodeViewModel: BarCodeViewModel
    @EnvironmentObject var mainViewModel: MainViewModel
    @EnvironmentObject var addTrackedFoodViewModel: AddTrackedFoodViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var isConfiguring = true
    @State private var torchOn = false
    @State private var scanLineY: CGFloat = -60

    @State private var selectedFood: FoodItem?
    @State private var quantity: String = ""

    var selectedDaytime: Int
    var selectedDate: Date

    private var preset: MealPreset { mealPreset(selectedDaytime) }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if isConfiguring {
                preparingView
            } else {
                CameraPreviewView { view in
                    print("CameraPreviewView: UIView erstellt – starte Scanning")
                    barCodeViewModel.startScanning(in: view)
                }
                .edgesIgnoringSafeArea(.all)

                scrim
                reticle
            }

            VStack {
                topBar
                Spacer()
                if !isConfiguring { hintCard }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 28)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            checkCameraAuthorization { granted in
                if granted {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isConfiguring = false
                    }
                }
            }
        }
        .onChange(of: barCodeViewModel.product?.id) { _, _ in
            if let product = barCodeViewModel.product {
                selectedFood = product
            }
        }
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { gesture in
                    if gesture.translation.width > 50 {
                        barCodeViewModel.stopScanning()
                        dismiss()
                    }
                }
        )
        .sheet(item: $selectedFood, onDismiss: { selectedFood = nil; quantity = "" }) { food in
            PortionSheet(
                title: food.name,
                subtitle: "\(formatNum(food.defaultQuantity)) \(food.unit) pro Portion",
                isFood: true,
                headerIcon: "barcode.viewfinder",
                baseDefault: food.defaultQuantity,
                unit: food.unit,
                baseKcal: Float(food.kcal),
                baseCarbs: food.carbohydrate,
                baseProtein: food.protein,
                baseFat: food.fat,
                tint: preset.tint,
                ctaLabel: "Zu \(preset.label) hinzufügen",
                ctaIcon: preset.icon,
                quantity: $quantity,
                onSave: {
                    if let q = Float(quantity.replacingOccurrences(of: ",", with: ".")) {
                        let multiplier = q / max(food.defaultQuantity, 0.0001)
                        barCodeViewModel.OpenFoodFactsFoodToDB(
                            name: food.name,
                            defaultQuantity: food.defaultQuantity,
                            unit: food.unit,
                            calories: food.kcal,
                            carbs: food.carbohydrate,
                            protein: food.protein,
                            fat: food.fat,
                            daytime: Int16(selectedDaytime),
                            quantity: multiplier,
                            selectedDate: selectedDate
                        )
                        mainViewModel.updateData()
                        addTrackedFoodViewModel.fetchFoodItems()
                        addTrackedFoodViewModel.fetchMealItems()
                        selectedFood = nil
                        dismiss()
                    }
                },
                onCancel: {
                    selectedFood = nil
                    dismiss()
                }
            )
            .presentationDetents([.fraction(0.6), .large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.regularMaterial)
        }
    }

    // MARK: - Preparing

    private var preparingView: some View {
        VStack(spacing: 14) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.white)
            Text("Kamera wird vorbereitet…")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous).fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.white.opacity(0.05))
            }
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 0.5)
            )
        )
    }

    // MARK: - Scrim with cutout

    private var scrim: some View {
        GeometryReader { geo in
            let w: CGFloat = 300, h: CGFloat = 180
            let cx = geo.size.width / 2
            let cy = geo.size.height / 2 - 20
            ZStack {
                Color.black.opacity(0.45)
                    .mask(
                        Rectangle()
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .frame(width: w, height: h)
                                    .position(x: cx, y: cy)
                                    .blendMode(.destinationOut)
                            )
                            .compositingGroup()
                    )
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    // MARK: - Reticle

    private var reticle: some View {
        GeometryReader { geo in
            let w: CGFloat = 300, h: CGFloat = 180
            let cx = geo.size.width / 2
            let cy = geo.size.height / 2 - 20
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.9), lineWidth: 1.5)
                    .frame(width: w, height: h)
                    .position(x: cx, y: cy)

                Rectangle()
                    .fill(LinearGradient(
                        colors: [Color.white.opacity(0), Color.white.opacity(0.95), Color.white.opacity(0)],
                        startPoint: .leading, endPoint: .trailing
                    ))
                    .frame(width: w - 40, height: 2)
                    .shadow(color: Color.white.opacity(0.7), radius: 6)
                    .position(x: cx, y: cy + scanLineY)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                            scanLineY = 55
                        }
                    }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            DarkGlassCircleButton(systemName: "xmark") {
                barCodeViewModel.stopScanning()
                dismiss()
            }
            Spacer()
            DarkGlassPill(icon: "barcode.viewfinder", text: "Barcode scannen")
            Spacer()
            DarkGlassCircleButton(systemName: torchOn ? "flashlight.on.fill" : "flashlight.off.fill",
                                  active: torchOn,
                                  tint: preset.tint) {
                barCodeViewModel.toggleTorch()
                torchOn.toggle()
            }
        }
    }

    // MARK: - Hint

    private var hintCard: some View {
        HStack(spacing: 10) {
            Image(systemName: "viewfinder")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(preset.tint)
            VStack(alignment: .leading, spacing: 2) {
                Text("Barcode in den Rahmen halten")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                Text("Nach rechts wischen zum Schließen")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.6))
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            ZStack {
                Capsule().fill(.ultraThinMaterial)
                Capsule().fill(Color.black.opacity(0.25))
            }
            .overlay(Capsule().stroke(Color.white.opacity(0.18), lineWidth: 0.5))
            .shadow(color: .black.opacity(0.35), radius: 14, x: 0, y: 6)
        )
    }

    private func checkCameraAuthorization(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { completion(granted) }
            }
        default:
            completion(false)
        }
    }
}

// MARK: - Dark glass controls

private struct DarkGlassCircleButton: View {
    let systemName: String
    var active: Bool = false
    var tint: Color = .white
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(active ? tint : .white)
                .frame(width: 42, height: 42)
                .background(
                    ZStack {
                        Circle().fill(.ultraThinMaterial)
                        Circle().fill(Color.black.opacity(active ? 0.10 : 0.30))
                    }
                    .overlay(Circle().stroke(active ? tint.opacity(0.55) : Color.white.opacity(0.22), lineWidth: 0.6))
                    .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 4)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct DarkGlassPill: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
            Text(text)
                .font(.system(size: 13, weight: .semibold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            ZStack {
                Capsule().fill(.ultraThinMaterial)
                Capsule().fill(Color.black.opacity(0.25))
            }
            .overlay(Capsule().stroke(Color.white.opacity(0.22), lineWidth: 0.5))
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 3)
        )
    }
}

// MARK: - Camera preview

struct CameraPreviewView: UIViewRepresentable {
    var onViewCreated: ((UIView) -> Void)? = nil

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        onViewCreated?(view)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    BarCodeView(selectedDaytime: 0, selectedDate: Date())
        .environmentObject(BarCodeViewModel(context: context))
        .environmentObject(MainViewModel(context: context))
        .environmentObject(AddTrackedFoodViewModel(context: context))
}
