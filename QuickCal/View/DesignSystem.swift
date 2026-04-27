//
//  DesignSystem.swift
//  QuickCal
//
//  Shared design tokens, primitives, and reusable view building blocks.
//

import SwiftUI
import UIKit

// MARK: - Tokens

enum QC {
    static let blue          = Color(hex: "0A84FF")
    static let blueDark      = Color(hex: "0F2055")
    static let blueRail      = Color(hex: "DCEBFF")
    static let blueWash      = Color(hex: "EEF5FF")
    static let carbs         = Color(hex: "14B8A6")
    static let carbsSoft     = Color(hex: "D7F2EE")
    static let protein       = Color(hex: "FF6A5B")
    static let proteinSoft   = Color(hex: "FFE1DD")
    static let fat           = Color(hex: "F5B63F")
    static let fatSoft       = Color(hex: "FCEBC8")
    static let fg            = Color.black
    static let fg2           = Color(red: 60/255, green: 60/255, blue: 67/255).opacity(0.60)
    static let fg3           = Color(red: 60/255, green: 60/255, blue: 67/255).opacity(0.30)
    static let separator     = Color(red: 60/255, green: 60/255, blue: 67/255).opacity(0.18)
    static let glassBorder   = Color.white.opacity(0.55)
    static let shadowColor   = Color(hex: "0F2055").opacity(0.10)
    static let fillTertiary       = Color(red: 60/255, green: 60/255, blue: 67/255).opacity(0.06)
    static let fillTertiarySolid  = Color(red: 60/255, green: 60/255, blue: 67/255).opacity(0.08)
}

// MARK: - Color hex helpers

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: Double
        switch hex.count {
        case 6:
            (a, r, g, b) = (1, Double((int >> 16) & 0xFF) / 255, Double((int >> 8) & 0xFF) / 255, Double(int & 0xFF) / 255)
        case 8:
            (a, r, g, b) = (Double((int >> 24) & 0xFF) / 255, Double((int >> 16) & 0xFF) / 255, Double((int >> 8) & 0xFF) / 255, Double(int & 0xFF) / 255)
        default:
            (a, r, g, b) = (1, 1, 1, 1)
        }
        self.init(red: r, green: g, blue: b, opacity: a)
    }

    func darker(by percentage: CGFloat) -> Color {
        let uiColor = UIColor(self)
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return Color(hue: Double(hue), saturation: Double(saturation),
                     brightness: Double(max(brightness - percentage, 0)), opacity: Double(alpha))
    }

    func lighter(by percentage: CGFloat) -> Color {
        let uiColor = UIColor(self)
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return Color(hue: Double(hue), saturation: Double(saturation),
                     brightness: Double(max(brightness + percentage, 0)), opacity: Double(alpha))
    }
}

// MARK: - Domain helpers

// MARK: Meal preset (daytime → label/icon/tint)

struct MealPreset {
    let label: String
    let tint: Color
    let icon: String
}

private let _mealPresets: [Int: MealPreset] = [
    0: MealPreset(label: "Frühstück",   tint: QC.fat,     icon: "sun.max.fill"),
    1: MealPreset(label: "Mittagessen", tint: QC.carbs,   icon: "fork.knife"),
    2: MealPreset(label: "Abendessen",  tint: QC.blue,    icon: "moon.fill"),
    3: MealPreset(label: "Snacks",      tint: QC.protein, icon: "leaf.fill"),
]

func mealPreset(_ daytime: Int) -> MealPreset {
    _mealPresets[daytime] ?? _mealPresets[0]!
}

// MARK: Number formatting

func formatNum(_ v: Float) -> String {
    if v.truncatingRemainder(dividingBy: 1) == 0 {
        return String(format: "%.0f", v)
    }
    return String(format: "%g", v)
}

// MARK: - Backdrops

struct LiquidBackdrop: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "F6FAFF"), Color(hex: "EEF3FA")],
                startPoint: .top, endPoint: .bottom
            )
            RadialGradient(
                colors: [QC.blue.opacity(0.22), .clear],
                center: UnitPoint(x: 0.18, y: 0.08),
                startRadius: 5, endRadius: 360
            )
            RadialGradient(
                colors: [QC.blueDark.opacity(0.14), .clear],
                center: UnitPoint(x: 0.92, y: 0.96),
                startRadius: 5, endRadius: 320
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - Glass surfaces

// MARK: Glass card (white-tinted material with double border + shadow)

struct GlassCard<Content: View>: View {
    var radius: CGFloat = 24
    var pad: CGFloat = 16
    @ViewBuilder var content: () -> Content
    var body: some View {
        content()
            .padding(pad)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .fill(.regularMaterial)
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .fill(Color.white.opacity(0.78))
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(Color.black.opacity(0.06), lineWidth: 0.5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .inset(by: 0.5)
                    .stroke(Color.white.opacity(0.85), lineWidth: 0.5)
            )
            .shadow(color: QC.blueDark.opacity(0.05), radius: 18, x: 0, y: 6)
            .shadow(color: QC.blueDark.opacity(0.03), radius: 2, x: 0, y: 1)
    }
}

// MARK: Glass card background (same recipe, used as `.background(...)`)

struct GlassCardBg: View {
    var radius: CGFloat = 20
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(.regularMaterial)
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(Color.white.opacity(0.78))
        }
        .overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .strokeBorder(Color.black.opacity(0.06), lineWidth: 0.5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .inset(by: 0.5)
                .stroke(Color.white.opacity(0.85), lineWidth: 0.5)
        )
        .shadow(color: QC.blueDark.opacity(0.06), radius: 18, x: 0, y: 6)
    }
}

// MARK: Glass capsule background

struct GlassCapsuleBg: View {
    var body: some View {
        ZStack {
            Capsule().fill(.regularMaterial)
            Capsule().fill(Color.white.opacity(0.55))
        }
        .overlay(Capsule().stroke(QC.glassBorder, lineWidth: 0.5))
        .shadow(color: QC.blueDark.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

extension View {
    func glassCapsule() -> some View {
        background(GlassCapsuleBg())
    }
}

// MARK: - Components

// MARK: Eyebrow label (uppercase, tracked, secondary)

struct EyebrowLabel: View {
    let text: String
    var size: CGFloat = 11
    var tracking: CGFloat = 0.7
    init(_ text: String, size: CGFloat = 11, tracking: CGFloat = 0.7) {
        self.text = text
        self.size = size
        self.tracking = tracking
    }
    var body: some View {
        Text(text)
            .font(.system(size: size, weight: .bold))
            .tracking(tracking)
            .foregroundStyle(QC.fg2)
            .textCase(.uppercase)
    }
}

// MARK: Circle glass button

struct CircleGlassButton: View {
    let systemName: String
    var size: CGFloat = 36
    var iconSize: CGFloat = 15
    var iconWeight: Font.Weight = .semibold
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: iconSize, weight: iconWeight))
                .foregroundStyle(QC.blue)
                .frame(width: size, height: size)
                .background(
                    ZStack {
                        Circle().fill(.regularMaterial)
                        Circle().fill(Color.white.opacity(0.55))
                    }
                    .overlay(Circle().stroke(QC.glassBorder, lineWidth: 0.5))
                    .shadow(color: QC.blueDark.opacity(0.06), radius: 8, x: 0, y: 2)
                )
        }
        .buttonStyle(.plain)
    }
}

