//
//  MainView.swift
//  QuickCal
//
//  Created by Lukas Esch on 09.10.24.
//

import SwiftUI
import CoreData

// MARK: - Main view

struct MainView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("onboarding") private var onboardingDone = false
    @State private var showingSettings = false

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
                            dateLabel: mainViewModel.dateLabel,
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

                        QuickStatsStrip(
                            steps: mainViewModel.steps,
                            stepsAuthorized: mainViewModel.stepsAuthorized
                        )
                            .padding(.horizontal, 16)
                            .padding(.top, 14)

                        SectionLabel(title: "MAHLZEITEN")
                            .padding(.horizontal, 16)
                            .padding(.top, 18)
                            .padding(.bottom, 8)

                        VStack(spacing: 12) {
                            mealCard(daytime: 0,
                                     kcal: mainViewModel.kcalMorning,
                                     carbs: mainViewModel.carbsMorning,
                                     protein: mainViewModel.proteinMorning,
                                     fat: mainViewModel.fatMorning)
                            mealCard(daytime: 1,
                                     kcal: mainViewModel.kcalMidday,
                                     carbs: mainViewModel.carbsMidday,
                                     protein: mainViewModel.proteinMidday,
                                     fat: mainViewModel.fatMidday)
                            mealCard(daytime: 2,
                                     kcal: mainViewModel.kcalEvening,
                                     carbs: mainViewModel.carbsEvening,
                                     protein: mainViewModel.proteinEvening,
                                     fat: mainViewModel.fatEvening)
                            mealCard(daytime: 3,
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

                // Temporarily disabled until Kalender/Statistik/Profil implemented
                // FloatingTabBar(active: $activeTab)
                //     .padding(.bottom, 12)
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
                    Spacer()
                }
                .presentationDetents([.fraction(0.51)])
                .presentationDragIndicator(.hidden)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .navigationDestination(isPresented: $mainViewModel.showAddTrackedFoodPanel) {
                if let daytime = mainViewModel.selectedDaytime {
                    AddTrackedFoodView(
                        showAddTrackedFoodPanel: $mainViewModel.showAddTrackedFoodPanel,
                        selectedDaytime: daytime,
                        selectedDate: mainViewModel.selectedDate
                    )
                }
            }
            .onAppear {
                mainViewModel.onAppear()
            }
            .onChange(of: scenePhase) { _, newPhase in
                mainViewModel.handleScenePhase(newPhase)
            }
        }
        .sheet(item: $selectedFood, onDismiss: { selectedFood = nil; quantity = "" }) { trackedFood in
            if let food = trackedFood.food {
                let p = mealPreset(Int(trackedFood.daytime))
                PortionSheet(
                    title: food.name ?? "Unbekannt",
                    subtitle: "\(formatNum(food.defaultQuantity)) \(food.unit ?? "") pro Portion",
                    isFood: true,
                    headerIcon: p.icon,
                    baseDefault: food.defaultQuantity,
                    unit: food.unit ?? "",
                    baseKcal: Float(food.kcal),
                    baseCarbs: food.carbohydrate,
                    baseProtein: food.protein,
                    baseFat: food.fat,
                    tint: p.tint,
                    ctaLabel: "Speichern",
                    ctaIcon: "checkmark",
                    quantity: $quantity,
                    onSave: {
                        if let q = Float(quantity.replacingOccurrences(of: ",", with: ".")) {
                            let multiplier = q / max(food.defaultQuantity, 0.0001)
                            mainViewModel.updateTrackedFoodQuantity(food: trackedFood, newQuantity: multiplier)
                            selectedFood = nil
                        }
                        mainViewModel.updateData()
                    },
                    onCancel: { selectedFood = nil }
                )
                .presentationDetents([.fraction(0.55), .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.regularMaterial)
            }
        }
    }

    // MARK: - Helpers

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
    private func mealCard(daytime: Int16,
                          kcal: Double, carbs: Double, protein: Double, fat: Double) -> some View {
        let p = mealPreset(Int(daytime))
        MealCardView(
            title: p.label,
            iconName: p.icon,
            tint: p.tint,
            totalKcal: kcal,
            totalCarbs: carbs,
            totalProtein: protein,
            totalFat: fat,
            items: mainViewModel.trackedFood(forDaytime: daytime),
            sourceDaytime: Int(daytime),
            onAdd: {
                mainViewModel.selectedDaytime = Int(daytime)
                mainViewModel.showAddTrackedFoodPanel.toggle()
            },
            onTapItem: { food in
                selectedFood = food
                let grams = food.quantity * (food.food?.defaultQuantity ?? 1)
                quantity = String(format: "%g", grams)
            },
            onDeleteItem: { food in
                if let idx = mainViewModel.trackedFood(forDaytime: daytime).firstIndex(of: food) {
                    mainViewModel.deleteTrackedFoodItem(at: IndexSet(integer: idx), forDaytime: daytime)
                }
            }
        )
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
            .glassCapsule()
            .contentShape(Capsule())
            .onTapGesture(perform: onDate)

            Spacer(minLength: 0)

            CircleGlassButton(systemName: "gearshape", size: 42, iconSize: 18, iconWeight: .regular, action: onSettings)
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
            VStack(spacing: 14) {
                ZStack(alignment: .bottom) {
                    KcalRingHalf(pct: pct)
                        .frame(width: 260, height: 130)

                    VStack(spacing: 2) {
                        EyebrowLabel("VERBRAUCHT", size: 10, tracking: 0.8)
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

// MARK: - Half ring

private struct KcalRingHalf: View {
    let pct: Double
    let strokeW: CGFloat = 14

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
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: strokeW, lineCap: .round)
                )
                .shadow(color: QC.blue.opacity(0.25), radius: 6, x: 0, y: 2)
                .animation(.easeOut(duration: 0.9), value: pct)
        }
    }
}

private struct HalfRingShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        // Match design: arc width = 80% of frame, endpoints at ~92% of frame height
        let r = rect.width * 0.40
        let center = CGPoint(x: rect.midX, y: rect.height * 0.92)
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
            EyebrowLabel(label, size: 10, tracking: 0.6)
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
    let steps: Int
    let stepsAuthorized: Bool

    private var stepsValue: String {
        guard stepsAuthorized else { return "–" }
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.locale = Locale(identifier: "de_DE")
        f.groupingSeparator = " "
        return f.string(from: NSNumber(value: steps)) ?? "0"
    }

    var body: some View {
        HStack(spacing: 8) {
            QuickStatCard(label: "Ø 7 TAGE", value: "1 842", unit: "kcal", disabled: false)
            QuickStatCard(label: "WASSER", value: "1.2", unit: "L", disabled: false)
            QuickStatCard(label: "SCHRITTE", value: stepsValue, unit: "", disabled: false)
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
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.regularMaterial)
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.8))
            }
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
                        MealRow(
                            name: food.displayName,
                            portion: food.portionDisplayString,
                            kcal: Int(food.totalKcalValue.rounded()),
                            isLast: idx == items.count - 1
                        )
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
                .fill(Color.white.opacity(0.94))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(Color.black.opacity(0.06), lineWidth: 0.5)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .inset(by: 0.5)
                        .stroke(Color.white.opacity(0.85), lineWidth: 0.5)
                )
                .shadow(color: QC.blueDark.opacity(0.12), radius: 30, x: 0, y: 8)
                .shadow(color: QC.blueDark.opacity(0.05), radius: 2, x: 0, y: 1)
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
    let name: String
    let portion: String
    let kcal: Int
    let isLast: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(QC.fg)
                        .lineLimit(1)
                    Text(portion)
                        .font(.system(size: 12))
                        .monospacedDigit()
                        .foregroundStyle(QC.fg2)
                }
                Spacer(minLength: 8)
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text("\(kcal)")
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
            ZStack {
                Capsule(style: .continuous).fill(.regularMaterial)
                Capsule(style: .continuous).fill(Color.white.opacity(0.6))
            }
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
