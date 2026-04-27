//
//  BarCodeView.swift
//  QuickCal
//
//  Created by Lukas Esch on 25.10.24.
//

import SwiftUI
import AVFoundation

// MARK: - Design tokens (mirrors AddTrackedFoodView)

private enum BC {
    static let blue        = Color(hex: "0A84FF")
    static let blueDark    = Color(hex: "0F2055")
    static let carbs       = Color(hex: "14B8A6")
    static let carbsSoft   = Color(hex: "D7F2EE")
    static let protein     = Color(hex: "FF6A5B")
    static let proteinSoft = Color(hex: "FFE1DD")
    static let fat         = Color(hex: "F5B63F")
    static let fatSoft     = Color(hex: "FCEBC8")
    static let fg          = Color.black
    static let fg2         = Color(red: 60/255, green: 60/255, blue: 67/255).opacity(0.60)
    static let fg3         = Color(red: 60/255, green: 60/255, blue: 67/255).opacity(0.30)
    static let glassBorder = Color.white.opacity(0.55)
}

private struct DaytimeTint {
    let label: String
    let icon: String
    let tint: Color
}

private func daytimeTint(_ d: Int) -> DaytimeTint {
    switch d {
    case 1: return DaytimeTint(label: "Mittagessen", icon: "fork.knife",    tint: BC.carbs)
    case 2: return DaytimeTint(label: "Abendessen",  icon: "moon.fill",     tint: BC.blue)
    case 3: return DaytimeTint(label: "Snacks",      icon: "leaf.fill",     tint: BC.protein)
    default: return DaytimeTint(label: "Frühstück",  icon: "sun.max.fill",  tint: BC.fat)
    }
}

private func bcFormatNum(_ v: Float) -> String {
    if v.truncatingRemainder(dividingBy: 1) == 0 { return String(format: "%.0f", v) }
    return String(format: "%g", v)
}

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

    private var preset: DaytimeTint { daytimeTint(selectedDaytime) }

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
            OFFPortionSheet(
                food: food,
                tint: preset.tint,
                ctaIcon: preset.icon,
                ctaLabel: "Zu \(preset.label) hinzufügen",
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

// MARK: - OFF portion sheet (matches AddTrackedFoodView's PortionSheet)

private struct OFFPortionSheet: View {
    let food: FoodItem
    let tint: Color
    let ctaIcon: String
    let ctaLabel: String
    @Binding var quantity: String
    let onSave: () -> Void
    let onCancel: () -> Void

    private var qtyVal: Float {
        Float(quantity.replacingOccurrences(of: ",", with: ".")) ?? food.defaultQuantity
    }
    private var factor: Float { qtyVal / max(food.defaultQuantity, 0.0001) }
    private var liveKcal: Int { Int((Float(food.kcal) * factor).rounded()) }
    private var liveC: Float { food.carbohydrate * factor }
    private var liveP: Float { food.protein * factor }
    private var liveF: Float { food.fat * factor }
    private var presets: [Float] {
        [max(0.5, food.defaultQuantity * 0.5), food.defaultQuantity, food.defaultQuantity * 1.5, food.defaultQuantity * 2]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).fill(tint.opacity(0.18))
                    Image(systemName: "barcode.viewfinder")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(tint)
                }
                .frame(width: 42, height: 42)
                VStack(alignment: .leading, spacing: 3) {
                    Text(food.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(BC.fg)
                        .lineLimit(2)
                    Text("\(bcFormatNum(food.defaultQuantity)) \(food.unit) pro Portion")
                        .font(.system(size: 12))
                        .foregroundStyle(BC.fg2)
                        .lineLimit(2)
                }
                Spacer()
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("MENGE")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(BC.fg2)
                HStack(spacing: 10) {
                    OFFStepperButton(symbol: "minus") {
                        let step: Float = max(1, food.defaultQuantity * 0.5)
                        let next = max(1, qtyVal - step)
                        quantity = bcFormatNum(next)
                    }
                    HStack(spacing: 6) {
                        TextField(bcFormatNum(food.defaultQuantity), text: $quantity)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 24, weight: .heavy, design: .rounded))
                            .monospacedDigit()
                            .multilineTextAlignment(.center)
                            .foregroundStyle(BC.fg)
                        Text(food.unit)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(BC.fg2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.7))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(BC.glassBorder, lineWidth: 0.5))
                    )
                    OFFStepperButton(symbol: "plus", tinted: true) {
                        let step: Float = max(1, food.defaultQuantity * 0.5)
                        quantity = bcFormatNum(qtyVal + step)
                    }
                }

                HStack(spacing: 6) {
                    ForEach(presets.indices, id: \.self) { i in
                        let v = presets[i]
                        let active = abs(qtyVal - v) < 0.01
                        Button {
                            quantity = bcFormatNum(v)
                        } label: {
                            Text("\(bcFormatNum(v)) \(food.unit)")
                                .font(.system(size: 12, weight: .semibold))
                                .monospacedDigit()
                                .foregroundStyle(active ? BC.blue : BC.fg)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 7)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(active ? BC.blue.opacity(0.14) : Color(red: 60/255, green: 60/255, blue: 67/255).opacity(0.06))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 4)
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(liveKcal)")
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(
                            LinearGradient(colors: [BC.blueDark, BC.blue],
                                           startPoint: .top, endPoint: .bottom)
                        )
                    Text("kcal")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(BC.fg2)
                    Spacer()
                    Text("GESAMT")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(BC.fg2)
                }
                HStack(spacing: 10) {
                    OFFMacroBar(label: "K", value: liveC, target: 200, color: BC.carbs, soft: BC.carbsSoft)
                    OFFMacroBar(label: "P", value: liveP, target: 120, color: BC.protein, soft: BC.proteinSoft)
                    OFFMacroBar(label: "F", value: liveF, target: 70, color: BC.fat, soft: BC.fatSoft)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.55))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(BC.glassBorder, lineWidth: 0.5))
            )

            Button(action: onSave) {
                HStack(spacing: 8) {
                    Image(systemName: ctaIcon)
                        .font(.system(size: 13, weight: .bold))
                    Text(ctaLabel)
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(LinearGradient(colors: [tint, tint.opacity(0.86)],
                                             startPoint: .top, endPoint: .bottom))
                        .shadow(color: tint.opacity(0.40), radius: 12, x: 0, y: 6)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(20)
    }
}

private struct OFFStepperButton: View {
    let symbol: String
    var tinted: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(tinted ? BC.blue : BC.fg)
                .frame(width: 38, height: 38)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(tinted
                              ? BC.blue.opacity(0.14)
                              : Color(red: 60/255, green: 60/255, blue: 67/255).opacity(0.08))
                )
        }
        .buttonStyle(.plain)
    }
}

private struct OFFMacroBar: View {
    let label: String
    let value: Float
    let target: Float
    let color: Color
    let soft: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(BC.fg2)
                Spacer()
                HStack(spacing: 1) {
                    Text(String(format: "%.0f", value))
                        .font(.system(size: 11, weight: .semibold))
                        .monospacedDigit()
                        .foregroundStyle(BC.fg)
                    Text("g")
                        .font(.system(size: 11))
                        .foregroundStyle(BC.fg2)
                }
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(soft)
                    Capsule().fill(color)
                        .frame(width: geo.size.width * CGFloat(min(value / target, 1)))
                }
            }
            .frame(height: 5)
        }
        .frame(maxWidth: .infinity)
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
