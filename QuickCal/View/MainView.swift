//
//  MainView.swift
//  QuickCal
//
//  Created by Lukas Esch on 09.10.24.
//

import SwiftUI
import CoreData

// MARK: - Design tokens

private enum QC {
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
}

// MARK: - Main view

struct MainView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("onboarding") private var onboardingDone = false
    @State private var showingSettings = false
    @State private var selectedDaytime: Int? = nil

    // Easter egg
    @State private var tapCount = 0
    @State private var isWobbling = false
    @State private var resetTimer: Timer?

    // Edit sheet
    @State private var selectedFood: TrackedFood?
    @State private var quantity: String = ""

    // Floating tab bar
    @State private var activeTab: TabKey = .home

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                LiquidBackdrop()

                ScrollView {
                    VStack(spacing: 0) {
                        TopHeader(
                            dateLabel: dateLabel,
                            isWobbling: isWobbling,
                            onIcon: handleIconTap,
                            onDate: { mainViewModel.showingDatePicker.toggle() },
                            onSettings: { showingSettings.toggle() }
                        )
                        .padding(.top, 6)

                        Spacer().frame(height: 14)

                        KcalHeroCard(
                            kcal: mainViewModel.kcalReached,
                            goal: mainViewModel.kcalGoal,
                            pct: mainViewModel.kcalProgressPercentage,
                            carbsValue: mainViewModel.carbsReached,
                            carbsGoal: mainViewModel.carbsGoal,
                            proteinValue: mainViewModel.proteinReached,
                            proteinGoal: mainViewModel.proteinGoal,
                            fatValue: mainViewModel.fatReached,
                            fatGoal: mainViewModel.fatGoal
                        )
                        .padding(.horizontal, 16)

                        QuickStatsStrip()
                            .padding(.horizontal, 16)
                            .padding(.top, 14)

                        SectionLabel(title: "MAHLZEITEN")
                            .padding(.horizontal, 16)
                            .padding(.top, 18)
                            .padding(.bottom, 8)

                        VStack(spacing: 12) {
                            mealCard(daytime: 0, title: "Frühstück",
                                     iconName: "sun.max.fill", tint: QC.fat,
                                     kcal: mainViewModel.kcalMorning,
                                     carbs: mainViewModel.carbsMorning,
                                     protein: mainViewModel.proteinMorning,
                                     fat: mainViewModel.fatMorning)
                            mealCard(daytime: 1, title: "Mittagessen",
                                     iconName: "fork.knife", tint: QC.carbs,
                                     kcal: mainViewModel.kcalMidday,
                                     carbs: mainViewModel.carbsMidday,
                                     protein: mainViewModel.proteinMidday,
                                     fat: mainViewModel.fatMidday)
                            mealCard(daytime: 2, title: "Abendessen",
                                     iconName: "moon.fill", tint: QC.blue,
                                     kcal: mainViewModel.kcalEvening,
                                     carbs: mainViewModel.carbsEvening,
                                     protein: mainViewModel.proteinEvening,
                                     fat: mainViewModel.fatEvening)
                            mealCard(daytime: 3, title: "Snacks",
                                     iconName: "leaf.fill", tint: QC.protein,
                                     kcal: mainViewModel.kcalSnacks,
                                     carbs: mainViewModel.carbsSnacks,
                                     protein: mainViewModel.proteinSnacks,
                                     fat: mainViewModel.fatSnacks)
                        }
                        .padding(.horizontal, 16)

                        Spacer().frame(height: 140) // room for floating tab bar
                    }
                }
                .scrollIndicators(.hidden)

                FloatingTabBar(active: $activeTab)
                    .padding(.bottom, 12)
            }
            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $mainViewModel.showingDatePicker) {
                VStack {
                    DatePicker(
                        "Datum auswählen:",
                        selection: $mainViewModel.selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .onChange(of: mainViewModel.selectedDate) { _, _ in
                        mainViewModel.showingDatePicker = false
                        mainViewModel.updateData()
                    }
                    Spacer()
                }
                .presentationDetents([.fraction(0.51)])
                .presentationDragIndicator(.hidden)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $mainViewModel.showAddTrackedFoodPanel) {
                if let daytime = selectedDaytime {
                    AddTrackedFoodView(
                        showAddTrackedFoodPanel: $mainViewModel.showAddTrackedFoodPanel,
                        selectedDaytime: daytime,
                        selectedDate: mainViewModel.selectedDate
                    )
                }
            }
            .onAppear {
                if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                    mainViewModel.kcalGoal = 2000
                    mainViewModel.kcalReached = 0
                    mainViewModel.carbsGoal = 200
                    mainViewModel.proteinGoal = 100
                    mainViewModel.fatGoal = 70
                } else {
                    mainViewModel.checkAndCalculateDailyCalories()
                }
                mainViewModel.updateData()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
                mainViewModel.selectedDate = Date()
                mainViewModel.updateData()
            }
            .task(id: scenePhase) {
                if scenePhase == .active {
                    let today = Calendar.current.startOfDay(for: Date())
                    if !Calendar.current.isDate(mainViewModel.selectedDate, inSameDayAs: today) {
                        mainViewModel.selectedDate = today
                        mainViewModel.updateData()
                    }
                }
            }
        }
        .sheet(item: $selectedFood, onDismiss: { selectedFood = nil; quantity = "" }) { trackedFood in
            CustomAlertEdit(
                quantity: $quantity,
                foodItem: trackedFood.food,
                onSave: {
                    if let q = Float(quantity.replacingOccurrences(of: ",", with: ".")) {
                        mainViewModel.updateTrackedFoodQuantity(food: trackedFood, newQuantity: q)
                        selectedFood = nil
                    }
                    mainViewModel.updateData()
                },
                onCancel: { selectedFood = nil }
            )
            .presentationDetents([.fraction(0.4)])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Helpers

    private var dateLabel: String {
        let cal = Calendar.current
        let date = mainViewModel.selectedDate
        if cal.isDate(date, inSameDayAs: Date()) { return "Heute" }
        if let y = cal.date(byAdding: .day, value: -1, to: Date()),
           cal.isDate(date, inSameDayAs: y) { return "Gestern" }
        if let v = cal.date(byAdding: .day, value: -2, to: Date()),
           cal.isDate(date, inSameDayAs: v) { return "Vorgestern" }
        let f = DateFormatter()
        f.locale = Locale(identifier: "de_DE")
        f.dateFormat = "d. MMMM"
        return f.string(from: date)
    }

    private func handleIconTap() {
        tapCount += 1
        resetTimer?.invalidate()
        if tapCount == 3 {
            triggerWobble()
            tapCount = 0
        } else {
            resetTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                tapCount = 0
            }
        }
    }

    private func triggerWobble() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.4, blendDuration: 0.2)) {
            isWobbling = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation { isWobbling = false }
        }
    }

    @ViewBuilder
    private func mealCard(daytime: Int16, title: String, iconName: String, tint: Color,
                          kcal: Double, carbs: Double, protein: Double, fat: Double) -> some View {
        MealCardView(
            title: title,
            iconName: iconName,
            tint: tint,
            totalKcal: kcal,
            totalCarbs: carbs,
            totalProtein: protein,
            totalFat: fat,
            items: mainViewModel.trackedFood(forDaytime: daytime),
            sourceDaytime: Int(daytime),
            onAdd: {
                selectedDaytime = Int(daytime)
                mainViewModel.showAddTrackedFoodPanel.toggle()
            },
            onTapItem: { food in
                selectedFood = food
                quantity = String(format: "%g", food.quantity)
            },
            onDeleteItem: { food in
                if let idx = mainViewModel.trackedFood(forDaytime: daytime).firstIndex(of: food) {
                    mainViewModel.deleteTrackedFoodItem(at: IndexSet(integer: idx), forDaytime: daytime)
                }
            }
        )
    }
}

// MARK: - Backdrop

private struct LiquidBackdrop: View {
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

// MARK: - Glass card

private struct GlassCard<Content: View>: View {
    var radius: CGFloat = 24
    var pad: CGFloat = 16
    @ViewBuilder var content: () -> Content
    var body: some View {
        content()
            .padding(pad)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .fill(Color.white.opacity(0.25))
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(QC.glassBorder, lineWidth: 0.5)
            )
            .shadow(color: QC.shadowColor, radius: 20, x: 0, y: 8)
    }
}

// MARK: - Top header

private struct TopHeader: View {
    let dateLabel: String
    let isWobbling: Bool
    let onIcon: () -> Void
    let onDate: () -> Void
    let onSettings: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image("Icon")
                .resizable()
                .frame(width: 42, height: 42)
                .rotationEffect(.degrees(isWobbling ? -15 : 0))
                .scaleEffect(isWobbling ? 1.2 : 1)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isWobbling)
                .onTapGesture(perform: onIcon)

            Spacer(minLength: 0)

            HStack(spacing: 8) {
                Text(dateLabel)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(QC.blue)
                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(QC.blue)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule().fill(.ultraThinMaterial)
                    .overlay(Capsule().stroke(QC.glassBorder, lineWidth: 0.5))
                    .shadow(color: QC.blueDark.opacity(0.06), radius: 8, x: 0, y: 2)
            )
            .contentShape(Capsule())
            .onTapGesture(perform: onDate)

            Spacer(minLength: 0)

            Button(action: onSettings) {
                Image(systemName: "gearshape")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(QC.blue)
                    .frame(width: 42, height: 42)
                    .background(
                        Circle().fill(.ultraThinMaterial)
                            .overlay(Circle().stroke(QC.glassBorder, lineWidth: 0.5))
                            .shadow(color: QC.blueDark.opacity(0.06), radius: 8, x: 0, y: 2)
                    )
            }
        }
        .padding(.horizontal, 14)
    }
}

// MARK: - Kcal hero

private struct KcalHeroCard: View {
    let kcal: Double
    let goal: Double
    let pct: Double
    let carbsValue: Double
    let carbsGoal: Double
    let proteinValue: Double
    let proteinGoal: Double
    let fatValue: Double
    let fatGoal: Double

    private var remaining: Int { max(0, Int((goal - kcal).rounded())) }

    var body: some View {
        GlassCard(radius: 28, pad: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        RadialGradient(
                            colors: [QC.blue.opacity(0.10), .clear],
                            center: UnitPoint(x: 0.5, y: 0.0),
                            startRadius: 4, endRadius: 220
                        )
                    )
                    .allowsHitTesting(false)

                VStack(spacing: 14) {
                    ZStack(alignment: .bottom) {
                        KcalRingHalf(pct: pct)
                            .frame(width: 260, height: 144)

                        VStack(spacing: 2) {
                            Text("VERBRAUCHT")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(0.8)
                                .foregroundStyle(QC.fg2)
                            Text("\(Int(kcal.rounded()))")
                                .font(.system(size: 56, weight: .heavy, design: .rounded))
                                .kerning(-1.5)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [QC.blueDark, QC.blue],
                                        startPoint: .top, endPoint: .bottom
                                    )
                                )
                        }
                        .padding(.bottom, -2)
                    }

                    HStack(alignment: .center) {
                        FlankStat(label: "ZIEL", value: "\(Int(goal.rounded()))", unit: "kcal", align: .leading)
                        Spacer(minLength: 8)
                        Rectangle().fill(QC.separator).frame(width: 0.5, height: 28)
                        Spacer(minLength: 8)
                        FlankStat(label: "ÜBRIG", value: "\(remaining)", unit: "kcal", align: .trailing)
                    }
                    .padding(.horizontal, 6)

                    Rectangle().fill(QC.separator).frame(height: 0.5)

                    HStack(spacing: 12) {
                        MacroColumn(name: "Kohlenhydrate", value: carbsValue, goal: carbsGoal, color: QC.carbs, soft: QC.carbsSoft)
                        MacroColumn(name: "Protein", value: proteinValue, goal: proteinGoal, color: QC.protein, soft: QC.proteinSoft)
                        MacroColumn(name: "Fett", value: fatValue, goal: fatGoal, color: QC.fat, soft: QC.fatSoft)
                    }
                }
            }
        }
    }
}

// MARK: - Half ring

private struct KcalRingHalf: View {
    let pct: Double
    let strokeW: CGFloat = 11

    var body: some View {
        let clamped = min(max(pct, 0), 1)
        let over = pct > 1.0
        ZStack {
            HalfRingShape()
                .stroke(QC.blueRail, style: StrokeStyle(lineWidth: strokeW, lineCap: .round))
            HalfRingShape()
                .trim(from: 0, to: clamped)
                .stroke(
                    LinearGradient(
                        colors: over ? [QC.blue, .red] : [QC.blue, QC.blueDark],
                        startPoint: .leading, endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: strokeW, lineCap: .round)
                )
                .shadow(color: QC.blue.opacity(0.25), radius: 5, x: 0, y: 2)
                .animation(.easeOut(duration: 0.9), value: pct)
        }
        .padding(.horizontal, strokeW / 2)
    }
}

private struct HalfRingShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let r = min(rect.width / 2, rect.height)
        let center = CGPoint(x: rect.midX, y: rect.maxY)
        p.addArc(center: center, radius: r,
                 startAngle: .degrees(180), endAngle: .degrees(360),
                 clockwise: false)
        return p
    }
}

// MARK: - Flank stat

private struct FlankStat: View {
    let label: String
    let value: String
    let unit: String
    let align: HorizontalAlignment

    var body: some View {
        VStack(alignment: align, spacing: 2) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .tracking(0.6)
                .foregroundStyle(QC.fg2)
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(QC.fg)
                Text(unit)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(QC.fg2)
            }
        }
        .frame(maxWidth: .infinity, alignment: align == .leading ? .leading : .trailing)
    }
}

// MARK: - Macro column

private struct MacroColumn: View {
    let name: String
    let value: Double
    let goal: Double
    let color: Color
    let soft: Color

    private var pct: Double {
        guard goal > 0 else { return 0 }
        return min(value / goal, 1.0)
    }

    var body: some View {
        VStack(spacing: 6) {
            Text(name)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(QC.fg)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(soft)
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * pct)
                        .animation(.easeOut(duration: 0.9), value: pct)
                }
            }
            .frame(height: 8)
            Text("\(Int(value.rounded())) / \(Int(goal.rounded())) g")
                .font(.system(size: 11, weight: .medium))
                .monospacedDigit()
                .foregroundStyle(QC.fg2)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Quick stats strip

private struct QuickStatsStrip: View {
    var body: some View {
        HStack(spacing: 8) {
            QuickStatCard(label: "Ø 7 TAGE", value: "—", unit: "kcal", disabled: true)
            QuickStatCard(label: "WASSER", value: "—", unit: "L", disabled: true)
            QuickStatCard(label: "SCHRITTE", value: "—", unit: "", disabled: true)
        }
    }
}

private struct QuickStatCard: View {
    let label: String
    let value: String
    let unit: String
    let disabled: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .tracking(0.6)
                .foregroundStyle(QC.fg2)
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(value)
                    .font(.system(size: 17, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(QC.fg)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(QC.fg2)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(QC.glassBorder, lineWidth: 0.5)
                )
                .shadow(color: QC.shadowColor.opacity(0.6), radius: 8, x: 0, y: 2)
        )
        .opacity(disabled ? 0.5 : 1.0)
    }
}

// MARK: - Section label

private struct SectionLabel: View {
    let title: String
    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .tracking(0.6)
                .foregroundStyle(QC.fg2)
            Rectangle().fill(QC.separator).frame(height: 0.5)
        }
    }
}

// MARK: - Meal card

private struct MealCardView: View {
    let title: String
    let iconName: String
    let tint: Color
    let totalKcal: Double
    let totalCarbs: Double
    let totalProtein: Double
    let totalFat: Double
    let items: [TrackedFood]
    let sourceDaytime: Int
    let onAdd: () -> Void
    let onTapItem: (TrackedFood) -> Void
    let onDeleteItem: (TrackedFood) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(tint.opacity(0.18))
                    Image(systemName: iconName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(tint)
                }
                .frame(width: 30, height: 30)

                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(QC.fg)

                Spacer(minLength: 8)

                HStack(spacing: 4) {
                    Text("\(Int(totalKcal.rounded()))")
                        .font(.system(size: 13, weight: .semibold))
                        .monospacedDigit()
                        .foregroundStyle(QC.fg)
                    Text("kcal")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundStyle(QC.fg2)
                }

                CopyMenuView(sourceDaytime: sourceDaytime)
                    .foregroundStyle(QC.fg2)

                Button(action: onAdd) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(QC.blue)
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(QC.blue.opacity(0.12)))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 8)

            if !items.isEmpty {
                HStack(spacing: 12) {
                    macroChip(letter: "K", color: QC.carbs, value: totalCarbs)
                    macroChip(letter: "P", color: QC.protein, value: totalProtein)
                    macroChip(letter: "F", color: QC.fat, value: totalFat)
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 8)
            }

            Rectangle().fill(QC.separator).frame(height: 0.5)

            if items.isEmpty {
                Text("Noch nichts hinzugefügt")
                    .font(.system(size: 13))
                    .foregroundStyle(QC.fg3)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            } else {
                VStack(spacing: 0) {
                    ForEach(items.indices, id: \.self) { idx in
                        let food = items[idx]
                        MealRow(food: food, isLast: idx == items.count - 1)
                            .contentShape(Rectangle())
                            .onTapGesture { onTapItem(food) }
                            .contextMenu {
                                Button(role: .destructive) {
                                    onDeleteItem(food)
                                } label: {
                                    Label("Löschen", systemImage: "trash")
                                }
                            }
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.88))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(QC.glassBorder, lineWidth: 0.5)
                )
                .shadow(color: QC.shadowColor.opacity(0.6), radius: 8, x: 0, y: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    @ViewBuilder
    private func macroChip(letter: String, color: Color, value: Double) -> some View {
        HStack(spacing: 3) {
            Text(letter)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(color)
            Text("\(Int(value.rounded()))g")
                .font(.system(size: 11, weight: .regular))
                .monospacedDigit()
                .foregroundStyle(QC.fg2)
        }
    }
}

private struct MealRow: View {
    let food: TrackedFood
    let isLast: Bool

    var body: some View {
        let portion = food.quantity
        let kcal = food.food?.kcal ?? 0
        let defaultQuantity = food.food?.defaultQuantity ?? 0
        let totalKcal = Float(kcal) * portion
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(food.food?.name ?? "Unknown Food")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(QC.fg)
                        .lineLimit(1)
                    Text("\(String(format: "%.0f", portion * defaultQuantity)) \(food.food?.unit ?? "")")
                        .font(.system(size: 12))
                        .monospacedDigit()
                        .foregroundStyle(QC.fg2)
                }
                Spacer(minLength: 8)
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text("\(Int(totalKcal.rounded()))")
                        .font(.system(size: 15, weight: .semibold))
                        .monospacedDigit()
                        .foregroundStyle(QC.fg)
                    Text("kcal")
                        .font(.system(size: 12))
                        .foregroundStyle(QC.fg2)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)

            if !isLast {
                Rectangle().fill(QC.separator).frame(height: 0.5).padding(.leading, 16)
            }
        }
    }
}

// MARK: - Floating tab bar

private enum TabKey: String {
    case home, calendar, stats, profile
}

private struct FloatingTabBar: View {
    @Binding var active: TabKey

    var body: some View {
        HStack(spacing: 2) {
            tab(.home, label: "Heute", icon: "house.fill")
            tab(.calendar, label: "Kalender", icon: "calendar")
            tab(.stats, label: "Statistik", icon: "chart.bar.fill")
            tab(.profile, label: "Profil", icon: "person.fill")
        }
        .padding(6)
        .background(
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(Capsule(style: .continuous).stroke(QC.glassBorder, lineWidth: 0.5))
                .shadow(color: QC.shadowColor, radius: 24, x: 0, y: 8)
        )
    }

    @ViewBuilder
    private func tab(_ key: TabKey, label: String, icon: String) -> some View {
        let on = active == key
        let color = on ? QC.blue : QC.fg2
        Button {
            // Per spec: only Heute is implemented. Others remain inert.
            if key == .home { active = .home }
        } label: {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundStyle(color)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule().fill(on ? QC.blue.opacity(0.14) : .clear)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Edit sheet (unchanged behavior)

struct CustomAlertEdit: View {
    @Binding var quantity: String
    var foodItem: Food?
    var onSave: () -> Void
    var onCancel: () -> Void

    private var portionAmount: Float {
        Float(quantity.replacingOccurrences(of: ",", with: ".")) ?? 1.0
    }

    var body: some View {
        if let food = foodItem {
            VStack(alignment: .leading, spacing: 16) {
                VStack(spacing: 4) {
                    Text(food.name ?? "Unbekannt")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("\(String(format: "%.0f", food.defaultQuantity)) \(food.unit ?? "") pro Portion")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Menge")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    TextField("1", text: $quantity)
                        .font(.title2)
                        .keyboardType(.decimalPad)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                HStack {
                    Spacer()
                    Text("Kcal: \(String(format: "%.0f", Float(food.kcal) * portionAmount))")
                    Spacer()
                    Text("K: \(String(format: "%.1fg", food.carbohydrate * portionAmount))")
                    Spacer()
                    Text("P: \(String(format: "%.1fg", food.protein * portionAmount))")
                    Spacer()
                    Text("F: \(String(format: "%.1fg", food.fat * portionAmount))")
                    Spacer()
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Button(action: onSave) {
                    Text("Ändern")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(20)
        }
    }
}

// MARK: - Copy menu (unchanged)

struct CopyMenuView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    let sourceDaytime: Int

    var dayTimeName: String {
        switch sourceDaytime {
        case 0: return "Frühstück"
        case 1: return "Mittagessen"
        case 2: return "Abendessen"
        case 3: return "Snacks"
        default: return "Unbekannt"
        }
    }

    var body: some View {
        Menu {
            Section("Kopieren zu:") {
                let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
                Button {
                    mainViewModel.copyEntriesToDate(daytime: sourceDaytime, targetDate: yesterday)
                } label: {
                    Text("\(dayTimeName) (gestern)")
                }
                .disabled(Calendar.current.isDate(yesterday, inSameDayAs: mainViewModel.selectedDate))

                let today = Date()
                Button {
                    mainViewModel.copyEntriesToDate(daytime: sourceDaytime, targetDate: today)
                } label: {
                    Text("\(dayTimeName) (heute)")
                }
                .disabled(Calendar.current.isDate(today, inSameDayAs: mainViewModel.selectedDate))

                let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
                Button {
                    mainViewModel.copyEntriesToDate(daytime: sourceDaytime, targetDate: tomorrow)
                } label: {
                    Text("\(dayTimeName) (morgen)")
                }
                .disabled(Calendar.current.isDate(tomorrow, inSameDayAs: mainViewModel.selectedDate))
            }
            .textCase(nil)
        } label: {
            Image(systemName: "doc.on.doc")
                .font(.system(size: 13, weight: .semibold))
        }
        .textCase(nil)
    }
}

// MARK: - Color hex helpers (kept as extension for app-wide use)

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

// MARK: - Preview

#Preview {
    let context = PersistenceController.preview.container.viewContext
    return MainView()
        .environment(\.managedObjectContext, context)
        .environmentObject(MainViewModel(context: context))
        .environmentObject(SettingsViewModel(context: context))
        .environmentObject(AddTrackedFoodViewModel(context: context))
        .environmentObject(CreateMealPanelViewModel(context: context))
        .environmentObject(BarCodeViewModel(context: context))
}
