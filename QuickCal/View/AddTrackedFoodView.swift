//
//  AddTrackedFoodView.swift
//  QuickCal
//
//  Created by Lukas Esch on 05.11.24.
//

import SwiftUI
import CoreData
import UIKit

// Enable interactive swipe-back even when the navigation bar is hidden.
extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }
}

// MARK: - Design tokens

private enum QC {
    static let blue          = Color(hex: "0A84FF")
    static let blueDark      = Color(hex: "0F2055")
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

// MARK: - Meal preset (per daytime)

private struct MealPreset {
    let label: String
    let tint: Color
    let icon: String
}

private let MEAL_PRESETS: [Int: MealPreset] = [
    0: MealPreset(label: "Frühstück",   tint: QC.fat,     icon: "sun.max.fill"),
    1: MealPreset(label: "Mittagessen", tint: QC.carbs,   icon: "fork.knife"),
    2: MealPreset(label: "Abendessen",  tint: QC.blue,    icon: "moon.fill"),
    3: MealPreset(label: "Snacks",      tint: QC.protein, icon: "leaf.fill"),
]

private func preset(_ d: Int) -> MealPreset { MEAL_PRESETS[d] ?? MEAL_PRESETS[0]! }

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

// MARK: - Main view

struct AddTrackedFoodView: View {
    @Binding var showAddTrackedFoodPanel: Bool
    @EnvironmentObject var addTrackedFoodViewModel: AddTrackedFoodViewModel
    @EnvironmentObject var mainViewModel: MainViewModel
    @EnvironmentObject var openFoodFactsViewModel: OpenFoodFactsViewModel
    @EnvironmentObject var createMealPanelViewModel: CreateMealPanelViewModel
    @EnvironmentObject var barCodeViewModel: BarCodeViewModel
    var selectedDaytime: Int
    var selectedDate: Date

    @Environment(\.dismiss) private var dismiss

    @State private var daytime: Int = 0
    @State private var mode: SourceMode = .food
    @State private var searchText: String = ""
    @State private var searchFocused: Bool = false

    @State private var selectedFood: Food?
    @State private var selectedMeal: Meal?
    @State private var editFood: Food?
    @State private var quantity: String = ""

    @State private var showFullScreenBarCodeView = false
    @State private var navigateToCreateFood = false
    @State private var navigateToCreateMeal = false
    @State private var navigateToOpenFoodFacts = false

    @State private var newName: String = ""
    @State private var newUnit: String = ""
    @State private var newDefaultQuantity: String = ""
    @State private var newCalories: String = ""
    @State private var newCarbs: String = ""
    @State private var newProtein: String = ""
    @State private var newFat: String = ""

    enum SourceMode { case food, meal }

    private var p: MealPreset { preset(daytime) }

    var body: some View {
        ZStack(alignment: .bottom) {
            LiquidBackdrop()

            ScrollView {
                VStack(spacing: 0) {
                    header

                    SourceSegmented(value: $mode)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 10)

                    sectionHeader
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)

                    if mode == .food {
                        foodList
                    } else {
                        mealList
                    }

                    Spacer().frame(height: 130)
                }
                .padding(.top, 6)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)

            BottomSearchDock(
                text: $searchText,
                focused: $searchFocused,
                onScan: { showFullScreenBarCodeView = true }
            )
            .padding(.bottom, 12)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            daytime = selectedDaytime
            addTrackedFoodViewModel.fetchFoodItems()
            addTrackedFoodViewModel.fetchMealItems()
            createMealPanelViewModel.clearStruct()
        }
        .onChange(of: searchText) { _, v in
            addTrackedFoodViewModel.filterFoodItems(by: v)
            addTrackedFoodViewModel.filterMealItems(by: v)
        }
        .navigationDestination(isPresented: $navigateToCreateFood) { CreateFoodPanelView() }
        .navigationDestination(isPresented: $navigateToCreateMeal) { CreateMealPanelView() }
        .navigationDestination(isPresented: $navigateToOpenFoodFacts) {
            OpenFoodFactsView(selectedDaytime: daytime, selectedDate: selectedDate)
        }
        .fullScreenCover(isPresented: $showFullScreenBarCodeView) {
            BarCodeView(selectedDaytime: daytime, selectedDate: selectedDate)
        }
        .sheet(item: $selectedFood, onDismiss: { selectedFood = nil; quantity = "" }) { food in
            PortionSheet(
                title: food.name ?? "Unbekannt",
                subtitle: "\(formatNum(food.defaultQuantity)) \(food.unit ?? "") pro Portion",
                isFood: true,
                baseDefault: food.defaultQuantity,
                unit: food.unit ?? "",
                baseKcal: Float(food.kcal),
                baseCarbs: food.carbohydrate,
                baseProtein: food.protein,
                baseFat: food.fat,
                tint: p.tint,
                ctaLabel: "Zu \(p.label) hinzufügen",
                ctaIcon: p.icon,
                quantity: $quantity,
                onSave: {
                    if let q = Float(quantity.replacingOccurrences(of: ",", with: ".")) {
                        let multiplier = q / max(food.defaultQuantity, 0.0001)
                        addTrackedFoodViewModel.addTrackedFood(
                            food: food, quantity: multiplier,
                            daytime: Int16(daytime), selectedDate: selectedDate
                        )
                        selectedFood = nil
                        mainViewModel.updateData()
                    }
                },
                onCancel: { selectedFood = nil }
            )
            .presentationDetents([.fraction(0.55), .large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.regularMaterial)
        }
        .sheet(item: $selectedMeal, onDismiss: { selectedMeal = nil; quantity = "" }) { meal in
            PortionSheet(
                title: meal.name ?? "Unbekannt",
                subtitle: mealIngredients(meal),
                isFood: false,
                baseDefault: Float(meal.defaultQuantity),
                unit: meal.unit ?? "Portion",
                baseKcal: Float(meal.kcal) / Float(max(meal.defaultQuantity, 1)),
                baseCarbs: meal.carbohydrate / Float(max(meal.defaultQuantity, 1)),
                baseProtein: meal.protein / Float(max(meal.defaultQuantity, 1)),
                baseFat: meal.fat / Float(max(meal.defaultQuantity, 1)),
                tint: p.tint,
                ctaLabel: "Zu \(p.label) hinzufügen",
                ctaIcon: p.icon,
                quantity: $quantity,
                onSave: {
                    if let q = Float(quantity.replacingOccurrences(of: ",", with: ".")) {
                        addTrackedFoodViewModel.addTrackedMeal(
                            meal: meal, quantity: q,
                            daytime: Int16(daytime), selectedDate: selectedDate
                        )
                        selectedMeal = nil
                        mainViewModel.updateData()
                    }
                },
                onCancel: { selectedMeal = nil }
            )
            .presentationDetents([.fraction(0.55), .large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.regularMaterial)
        }
        .sheet(item: $editFood, onDismiss: { editFood = nil }) { food in
            CustomAlertEditFoodAttributes(
                newName: $newName, newUnit: $newUnit,
                newDefaultQuantity: $newDefaultQuantity,
                newCalories: $newCalories, newCarbs: $newCarbs,
                newProtein: $newProtein, newFat: $newFat,
                foodItem: food,
                onSave: {
                    addTrackedFoodViewModel.updateFoodItemAttributes(
                        food: food, newName: newName, newUnit: newUnit,
                        newDefaultQuantity: newDefaultQuantity, newCalories: newCalories,
                        newCarbs: newCarbs, newProtein: newProtein, newFat: newFat
                    )
                    editFood = nil
                    mainViewModel.updateData()
                },
                onCancel: { editFood = nil }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .scrollContentBackground(.hidden)
        }
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            HStack {
                CircleGlassButton(systemName: "chevron.left") {
                    showAddTrackedFoodPanel = false
                    dismiss()
                }
                Spacer()
                CircleGlassButton(systemName: "checkmark") {
                    showAddTrackedFoodPanel = false
                    dismiss()
                }
            }
            MealModePill(daytime: $daytime)
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 10)
    }

    private var sectionHeader: some View {
        HStack(spacing: 10) {
            Text("Zuletzt benutzt")
                .font(.system(size: 12, weight: .bold))
                .tracking(0.7)
                .foregroundStyle(QC.fg2)
                .textCase(.uppercase)
            Spacer()
            Button {
                if mode == .food { navigateToCreateFood = true }
                else { navigateToCreateMeal = true }
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .bold))
                    Text(mode == .food ? "Lebensmittel erstellen" : "Gericht erstellen")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(QC.blue)
                .padding(.horizontal, 11)
                .padding(.vertical, 5)
                .background(
                    Capsule().fill(QC.blue.opacity(0.10))
                        .overlay(Capsule().stroke(QC.blue.opacity(0.28), lineWidth: 0.5))
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Lists

    @ViewBuilder
    private var foodList: some View {
        let items = addTrackedFoodViewModel.foodItems
        if items.isEmpty {
            EmptyStateCreate(
                mode: mode, query: searchText,
                onCreateFood: { navigateToCreateFood = true },
                onCreateMeal: { navigateToCreateMeal = true },
                onScan: { showFullScreenBarCodeView = true }
            )
            .padding(.horizontal, 16)
        } else {
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element) { idx, food in
                    FoodResultRow(food: food, isLast: idx == items.count - 1)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            quantity = ""
                            selectedFood = food
                        }
                        .contextMenu {
                            Button { editFood = food } label: {
                                Label("Bearbeiten", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                if let i = addTrackedFoodViewModel.foodItems.firstIndex(of: food) {
                                    addTrackedFoodViewModel.deleteFoodItem(at: IndexSet(integer: i))
                                    mainViewModel.updateData()
                                }
                            } label: {
                                Label("Löschen", systemImage: "trash")
                            }
                        }
                }
            }
            .background(GlassCardBg())
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private var mealList: some View {
        let items = addTrackedFoodViewModel.mealItems
        if items.isEmpty {
            EmptyStateCreate(
                mode: mode, query: searchText,
                onCreateFood: { navigateToCreateFood = true },
                onCreateMeal: { navigateToCreateMeal = true },
                onScan: { showFullScreenBarCodeView = true }
            )
            .padding(.horizontal, 16)
        } else {
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element) { idx, meal in
                    MealResultRow(meal: meal, isLast: idx == items.count - 1,
                                  ingredients: mealIngredients(meal))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            quantity = ""
                            selectedMeal = meal
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                if let i = addTrackedFoodViewModel.mealItems.firstIndex(of: meal) {
                                    addTrackedFoodViewModel.deleteMealItem(at: IndexSet(integer: i))
                                }
                            } label: {
                                Label("Löschen", systemImage: "trash")
                            }
                        }
                }
            }
            .background(GlassCardBg())
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(.horizontal, 16)
        }
    }

    private func mealIngredients(_ meal: Meal) -> String {
        guard let mealFoods = meal.mealFood as? Set<MealFood> else { return "" }
        return mealFoods.compactMap { $0.food?.name }.sorted().joined(separator: ", ")
    }
}

// MARK: - Glass card background

private struct GlassCardBg: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.regularMaterial)
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.78))
        }
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.black.opacity(0.06), lineWidth: 0.5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .inset(by: 0.5)
                .stroke(Color.white.opacity(0.85), lineWidth: 0.5)
        )
        .shadow(color: QC.blueDark.opacity(0.06), radius: 18, x: 0, y: 6)
    }
}

// MARK: - Glass circle button

private struct CircleGlassButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(QC.blue)
                .frame(width: 36, height: 36)
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

// MARK: - Meal mode pill (dropdown)

private struct MealModePill: View {
    @Binding var daytime: Int

    @State private var dragX: CGFloat = 0
    @State private var menuOpen = false

    private let snapThreshold: CGFloat = 44

    var body: some View {
        let pre = preset(daytime)
        ZStack {
            // Adjacent peek labels (Camera-app style mode reveal)
            HStack(spacing: 14) {
                if daytime > 0 {
                    Text(preset(daytime - 1).label)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(preset(daytime - 1).tint.opacity(0.55))
                        .offset(x: dragX * 0.6 - 70)
                        .opacity(min(1, Double(dragX / snapThreshold)))
                }
                Spacer()
                if daytime < 3 {
                    Text(preset(daytime + 1).label)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(preset(daytime + 1).tint.opacity(0.55))
                        .offset(x: dragX * 0.6 + 70)
                        .opacity(min(1, Double(-dragX / snapThreshold)))
                }
            }
            .frame(width: 260)
            .allowsHitTesting(false)

            // Main pill
            HStack(spacing: 8) {
                Image(systemName: pre.icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(pre.tint)
                Text(pre.label)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(pre.tint)
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(pre.tint)
                    .rotationEffect(.degrees(menuOpen ? 180 : 0))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    Capsule().fill(.regularMaterial)
                    Capsule().fill(Color.white.opacity(0.55))
                }
                .overlay(Capsule().stroke(QC.glassBorder, lineWidth: 0.5))
                .shadow(color: QC.blueDark.opacity(0.06), radius: 8, x: 0, y: 2)
            )
            .offset(x: dragX)
            .scaleEffect(1 - min(0.04, abs(dragX) / 800))
            .contentShape(Capsule())
            .gesture(
                DragGesture(minimumDistance: 6)
                    .onChanged { v in
                        let t = v.translation.width
                        // Rubber band at edges
                        let lower = (daytime == 3 && t < 0) || (daytime == 0 && t > 0)
                        dragX = lower ? t * 0.25 : t
                    }
                    .onEnded { v in
                        let t = v.translation.width
                        let predicted = v.predictedEndTranslation.width
                        let trigger: CGFloat = 50
                        var next = daytime
                        if (t < -trigger || predicted < -trigger * 1.6) && daytime < 3 {
                            next = daytime + 1
                        } else if (t > trigger || predicted > trigger * 1.6) && daytime > 0 {
                            next = daytime - 1
                        }
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
                            daytime = next
                            dragX = 0
                        }
                    }
            )
            .onTapGesture {
                menuOpen.toggle()
            }
            .popover(isPresented: $menuOpen, attachmentAnchor: .point(.bottom), arrowEdge: .top) {
                VStack(spacing: 0) {
                    ForEach(0..<4, id: \.self) { i in
                        let m = preset(i)
                        Button {
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                daytime = i
                            }
                            menuOpen = false
                        } label: {
                            HStack(spacing: 10) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 7).fill(m.tint.opacity(0.18))
                                    Image(systemName: m.icon)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(m.tint)
                                }
                                .frame(width: 24, height: 24)
                                Text(m.label)
                                    .font(.system(size: 14, weight: i == daytime ? .semibold : .regular))
                                    .foregroundStyle(QC.fg)
                                Spacer()
                                if i == daytime {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(QC.blue)
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 11)
                            .background(i == daytime ? QC.blue.opacity(0.08) : Color.clear)
                        }
                        .buttonStyle(.plain)
                        if i < 3 {
                            Rectangle().fill(QC.separator).frame(height: 0.5).padding(.leading, 14)
                        }
                    }
                }
                .frame(width: 220)
                .presentationCompactAdaptation(.popover)
            }
        }
        .animation(.interactiveSpring(response: 0.2, dampingFraction: 0.85), value: dragX)
    }
}

// MARK: - Source segmented

private struct SourceSegmented: View {
    @Binding var value: AddTrackedFoodView.SourceMode

    var body: some View {
        HStack(spacing: 2) {
            seg(.food, label: "Lebensmittel", icon: "carrot.fill")
            seg(.meal, label: "Gerichte", icon: "fork.knife")
        }
        .padding(2)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(red: 120/255, green: 120/255, blue: 128/255).opacity(0.16))
        )
    }

    @ViewBuilder
    private func seg(_ key: AddTrackedFoodView.SourceMode, label: String, icon: String) -> some View {
        let on = value == key
        Button { value = key } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(label)
                    .font(.system(size: 13, weight: on ? .semibold : .medium))
            }
            .foregroundStyle(on ? QC.fg : QC.fg2)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(on ? Color.white : Color.clear)
                    .shadow(color: on ? Color.black.opacity(0.08) : .clear, radius: 1, x: 0, y: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Result rows

private struct FoodResultRow: View {
    let food: Food
    let isLast: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(food.name ?? "Unbekannt")
                        .font(.system(size: 14.5, weight: .medium))
                        .foregroundStyle(QC.fg)
                        .lineLimit(1)
                    HStack(spacing: 8) {
                        Text("\(formatNum(food.defaultQuantity)) \(food.unit ?? "")")
                            .font(.system(size: 11.5))
                            .foregroundStyle(QC.fg2)
                            .monospacedDigit()
                    }
                    HStack(spacing: 8) {
                        MacroMini(c: Double(food.carbohydrate), p: Double(food.protein), f: Double(food.fat))
                            .frame(width: 64, height: 4)
                        Text(macroSummary(food.carbohydrate, food.protein, food.fat))
                            .font(.system(size: 10.5))
                            .foregroundStyle(QC.fg2)
                            .monospacedDigit()
                    }
                    .padding(.top, 1)
                }
                Spacer(minLength: 8)
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text("\(food.kcal)")
                        .font(.system(size: 15, weight: .semibold))
                        .monospacedDigit()
                        .foregroundStyle(QC.fg)
                    Text("kcal")
                        .font(.system(size: 11))
                        .foregroundStyle(QC.fg2)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            if !isLast {
                Rectangle().fill(QC.separator).frame(height: 0.5)
            }
        }
    }

    private func macroSummary(_ c: Float, _ p: Float, _ f: Float) -> String {
        "K \(Int(c.rounded()))g  P \(Int(p.rounded()))g  F \(Int(f.rounded()))g"
    }
}

private struct MealResultRow: View {
    let meal: Meal
    let isLast: Bool
    let ingredients: String

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(QC.carbs.opacity(0.18))
                    Image(systemName: "fork.knife")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(QC.carbs)
                }
                .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(meal.name ?? "Unbekannt")
                        .font(.system(size: 14.5, weight: .medium))
                        .foregroundStyle(QC.fg)
                        .lineLimit(1)
                    if !ingredients.isEmpty {
                        Text(ingredients)
                            .font(.system(size: 11.5))
                            .foregroundStyle(QC.fg2)
                            .lineLimit(1)
                    }
                }
                Spacer(minLength: 8)
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text("\(meal.kcal)")
                            .font(.system(size: 14.5, weight: .semibold))
                            .monospacedDigit()
                            .foregroundStyle(QC.fg)
                        Text("kcal")
                            .font(.system(size: 10.5))
                            .foregroundStyle(QC.fg2)
                    }
                    Text("\(meal.defaultQuantity) \(meal.unit ?? "Portion")")
                        .font(.system(size: 11))
                        .foregroundStyle(QC.fg2)
                        .monospacedDigit()
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            if !isLast {
                Rectangle().fill(QC.separator).frame(height: 0.5)
            }
        }
    }
}

// MARK: - Macro mini bar

private struct MacroMini: View {
    let c: Double
    let p: Double
    let f: Double

    var body: some View {
        GeometryReader { geo in
            let cKcal = c * 4, pKcal = p * 4, fKcal = f * 9
            let total = max(cKcal + pKcal + fKcal, 1)
            HStack(spacing: 0) {
                Rectangle().fill(QC.carbs).frame(width: geo.size.width * cKcal / total)
                Rectangle().fill(QC.protein).frame(width: geo.size.width * pKcal / total)
                Rectangle().fill(QC.fat).frame(width: geo.size.width * fKcal / total)
            }
        }
        .background(QC.fg3.opacity(0.4))
        .clipShape(Capsule())
    }
}

// MARK: - Empty state

private struct EmptyStateCreate: View {
    let mode: AddTrackedFoodView.SourceMode
    let query: String
    let onCreateFood: () -> Void
    let onCreateMeal: () -> Void
    let onScan: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 4) {
                Text("🔍").font(.system(size: 36)).opacity(0.55)
                if query.isEmpty {
                    Text("Keine Treffer")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(QC.fg)
                } else {
                    (Text("Keine Treffer für ") + Text("„\(query)“").foregroundColor(QC.fg2))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(QC.fg)
                }
                Text("Du kannst es selbst hinzufügen.")
                    .font(.system(size: 13))
                    .foregroundStyle(QC.fg3)
            }
            .padding(.top, 8)

            HStack(spacing: 10) {
                CreateTile(
                    label: "Lebensmittel\nerstellen",
                    sub: "Eigenes mit Nährwerten anlegen",
                    icon: "carrot.fill", tint: QC.protein,
                    active: mode == .food,
                    action: onCreateFood
                )
                CreateTile(
                    label: "Gericht\nerstellen",
                    sub: "Mehrere Lebensmittel kombinieren",
                    icon: "fork.knife", tint: QC.carbs,
                    active: mode == .meal,
                    action: onCreateMeal
                )
            }

            Button(action: onScan) {
                HStack(spacing: 11) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8).fill(QC.blue.opacity(0.14))
                        Image(systemName: "barcode.viewfinder")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(QC.blue)
                    }
                    .frame(width: 30, height: 30)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Barcode scannen")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(QC.fg)
                        Text("Wenn das Produkt verpackt ist")
                            .font(.system(size: 11))
                            .foregroundStyle(QC.fg3)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(QC.fg3)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(GlassCardBg())
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
        }
    }
}

private struct CreateTile: View {
    let label: String
    let sub: String
    let icon: String
    let tint: Color
    let active: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10).fill(tint.opacity(0.18))
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(tint)
                }
                .frame(width: 34, height: 34)
                Spacer(minLength: 0)
                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(active ? tint : QC.fg)
                        .multilineTextAlignment(.leading)
                    Text(sub)
                        .font(.system(size: 11))
                        .foregroundStyle(QC.fg3)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 118, alignment: .topLeading)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(active
                              ? AnyShapeStyle(LinearGradient(colors: [tint.opacity(0.10), tint.opacity(0.05)], startPoint: .top, endPoint: .bottom))
                              : AnyShapeStyle(.regularMaterial))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(active ? tint.opacity(0.33) : QC.glassBorder, lineWidth: 0.5)
                )
                .shadow(color: active ? tint.opacity(0.15) : QC.blueDark.opacity(0.05), radius: 8, x: 0, y: 3)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Bottom search dock

private struct BottomSearchDock: View {
    @Binding var text: String
    @Binding var focused: Bool
    let onScan: () -> Void

    @FocusState private var fieldFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 9) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(QC.fg2)
                TextField("Suchen", text: $text)
                    .font(.system(size: 15))
                    .foregroundStyle(QC.fg)
                    .focused($fieldFocused)
                    .submitLabel(.search)
                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(QC.fg3)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    Capsule().fill(.regularMaterial)
                    Capsule().fill(Color.white.opacity(0.55))
                }
                .overlay(Capsule().stroke(QC.glassBorder, lineWidth: 0.5))
                .shadow(color: QC.blueDark.opacity(0.18), radius: 24, x: 0, y: 8)
            )

            Button(action: onScan) {
                Image(systemName: "barcode.viewfinder")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle().fill(QC.blue.opacity(0.92))
                            .overlay(Circle().stroke(Color.white.opacity(0.30), lineWidth: 0.5))
                            .shadow(color: QC.blue.opacity(0.40), radius: 12, x: 0, y: 6)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .onChange(of: fieldFocused) { _, v in focused = v }
    }
}

// MARK: - Portion sheet

private struct PortionSheet: View {
    let title: String
    let subtitle: String
    let isFood: Bool
    let baseDefault: Float
    let unit: String
    let baseKcal: Float
    let baseCarbs: Float
    let baseProtein: Float
    let baseFat: Float
    let tint: Color
    let ctaLabel: String
    let ctaIcon: String
    @Binding var quantity: String
    let onSave: () -> Void
    let onCancel: () -> Void

    private var qtyVal: Float {
        Float(quantity.replacingOccurrences(of: ",", with: ".")) ?? (isFood ? baseDefault : 1)
    }
    private var factor: Float { isFood ? qtyVal / max(baseDefault, 0.0001) : qtyVal }
    private var liveKcal: Int { Int((baseKcal * factor).rounded()) }
    private var liveC: Float { baseCarbs * factor }
    private var liveP: Float { baseProtein * factor }
    private var liveF: Float { baseFat * factor }
    private var presets: [Float] {
        if isFood {
            return [max(0.5, baseDefault * 0.5), baseDefault, baseDefault * 1.5, baseDefault * 2]
        }
        return [0.5, 1, 1.5, 2]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).fill(tint.opacity(0.18))
                    Image(systemName: isFood ? "carrot.fill" : "fork.knife")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(tint)
                }
                .frame(width: 42, height: 42)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(QC.fg)
                        .lineLimit(2)
                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundStyle(QC.fg2)
                            .lineLimit(2)
                    }
                }
                Spacer()
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("MENGE")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(QC.fg2)
                HStack(spacing: 10) {
                    StepperButton(symbol: "minus") {
                        let step: Float = isFood ? max(1, baseDefault * 0.5) : 0.5
                        let next = max(isFood ? 1 : 0.5, qtyVal - step)
                        quantity = formatNum(next)
                    }
                    HStack(spacing: 6) {
                        TextField(isFood ? formatNum(baseDefault) : "1", text: $quantity)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 24, weight: .heavy, design: .rounded))
                            .monospacedDigit()
                            .multilineTextAlignment(.center)
                            .foregroundStyle(QC.fg)
                        Text(unit)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(QC.fg2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.7))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(QC.glassBorder, lineWidth: 0.5))
                    )
                    StepperButton(symbol: "plus", tinted: true) {
                        let step: Float = isFood ? max(1, baseDefault * 0.5) : 0.5
                        quantity = formatNum(qtyVal + step)
                    }
                }

                HStack(spacing: 6) {
                    ForEach(presets.indices, id: \.self) { i in
                        let v = presets[i]
                        let active = abs(qtyVal - v) < 0.01
                        Button {
                            quantity = formatNum(v)
                        } label: {
                            Text("\(formatNum(v)) \(unit)")
                                .font(.system(size: 12, weight: .semibold))
                                .monospacedDigit()
                                .foregroundStyle(active ? QC.blue : QC.fg)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 7)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(active ? QC.blue.opacity(0.14) : Color(red: 60/255, green: 60/255, blue: 67/255).opacity(0.06))
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
                            LinearGradient(colors: [QC.blueDark, QC.blue],
                                           startPoint: .top, endPoint: .bottom)
                        )
                    Text("kcal")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(QC.fg2)
                    Spacer()
                    Text("GESAMT")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(QC.fg2)
                }
                HStack(spacing: 10) {
                    MacroBar(label: "K", value: liveC, target: 200, color: QC.carbs, soft: QC.carbsSoft)
                    MacroBar(label: "P", value: liveP, target: 120, color: QC.protein, soft: QC.proteinSoft)
                    MacroBar(label: "F", value: liveF, target: 70, color: QC.fat, soft: QC.fatSoft)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.55))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(QC.glassBorder, lineWidth: 0.5))
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

private struct StepperButton: View {
    let symbol: String
    var tinted: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(tinted ? QC.blue : QC.fg)
                .frame(width: 38, height: 38)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(tinted
                              ? QC.blue.opacity(0.14)
                              : Color(red: 60/255, green: 60/255, blue: 67/255).opacity(0.08))
                )
        }
        .buttonStyle(.plain)
    }
}

private struct MacroBar: View {
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
                    .foregroundStyle(QC.fg2)
                Spacer()
                HStack(spacing: 1) {
                    Text(String(format: "%.0f", value))
                        .font(.system(size: 11, weight: .semibold))
                        .monospacedDigit()
                        .foregroundStyle(QC.fg)
                    Text("g")
                        .font(.system(size: 11))
                        .foregroundStyle(QC.fg2)
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

// MARK: - Helpers

private func formatNum(_ v: Float) -> String {
    if v.truncatingRemainder(dividingBy: 1) == 0 {
        return String(format: "%.0f", v)
    }
    return String(format: "%g", v)
}

// MARK: - CustomFoodAlert (used by CreateMealIngredientsView)

struct CustomFoodAlert: View {
    @Binding var quantity: String
    var foodItem: Food
    var onSave: () -> Void
    var onCancel: () -> Void

    private var portionAmount: Float {
        Float(quantity.replacingOccurrences(of: ",", with: ".")) ?? 1.0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(spacing: 4) {
                Text(foodItem.name ?? "Unbekannt")
                    .font(.title2).fontWeight(.bold)
                Text("\(String(format: "%.0f", foodItem.defaultQuantity)) \(foodItem.unit ?? "") pro Portion")
                    .font(.subheadline).foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 6) {
                Text("Menge").font(.caption).foregroundStyle(.secondary).textCase(.uppercase)
                TextField("1", text: $quantity)
                    .font(.title2).keyboardType(.decimalPad)
                    .padding(10).background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            HStack {
                Spacer()
                Text("Kcal: \(String(format: "%.0f", Float(foodItem.kcal) * portionAmount))")
                Spacer()
                Text("K: \(String(format: "%.1fg", foodItem.carbohydrate * portionAmount))")
                Spacer()
                Text("P: \(String(format: "%.1fg", foodItem.protein * portionAmount))")
                Spacer()
                Text("F: \(String(format: "%.1fg", foodItem.fat * portionAmount))")
                Spacer()
            }
            .font(.subheadline).foregroundStyle(.secondary)

            Button(action: onSave) {
                Text("Hinzufügen")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(20)
    }
}

// MARK: - Edit food sheet (preserved)

struct CustomAlertEditFoodAttributes: View {
    @Binding var newName: String
    @Binding var newUnit: String
    @Binding var newDefaultQuantity: String
    @Binding var newCalories: String
    @Binding var newCarbs: String
    @Binding var newProtein: String
    @Binding var newFat: String
    var foodItem: Food
    var onSave: () -> Void
    var onCancel: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 11) {
                Text("Bearbeiten")
                    .font(.title2).fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Name").font(.caption).foregroundStyle(.secondary).textCase(.uppercase)
                    TextField("Neuer Name", text: $newName)
                        .submitLabel(.done)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .onAppear { newName = foodItem.name ?? "" }
                }

                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Portionsgröße").font(.caption).foregroundStyle(.secondary).textCase(.uppercase)
                        TextField("100", text: $newDefaultQuantity)
                            .keyboardType(.numberPad).submitLabel(.done)
                            .padding(8).background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .onAppear { newDefaultQuantity = String(foodItem.defaultQuantity) }
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Einheit").font(.caption).foregroundStyle(.secondary).textCase(.uppercase)
                        Picker("Einheit", selection: $newUnit) {
                            Text("Gramm").tag("g")
                            Text("Kilogramm").tag("kg")
                            Text("Milliliter").tag("ml")
                            Text("Liter").tag("l")
                            Text("Stück").tag("Stück")
                        }
                        .pickerStyle(.menu)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .onAppear { newUnit = foodItem.unit ?? "g" }
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Kalorien (kcal)").font(.caption).foregroundStyle(.secondary).textCase(.uppercase)
                    TextField("83", text: $newCalories)
                        .keyboardType(.decimalPad).submitLabel(.done)
                        .padding(10).background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .onAppear { newCalories = String(foodItem.kcal) }
                }

                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("K (g)").font(.caption).foregroundStyle(.secondary).textCase(.uppercase)
                        TextField("43", text: $newCarbs)
                            .keyboardType(.decimalPad).submitLabel(.done)
                            .padding(8).background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .onAppear { newCarbs = String(foodItem.carbohydrate) }
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("P (g)").font(.caption).foregroundStyle(.secondary).textCase(.uppercase)
                        TextField("5.1", text: $newProtein)
                            .keyboardType(.decimalPad).submitLabel(.done)
                            .padding(8).background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .onAppear { newProtein = String(foodItem.protein) }
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("F (g)").font(.caption).foregroundStyle(.secondary).textCase(.uppercase)
                        TextField("1.3", text: $newFat)
                            .keyboardType(.decimalPad).submitLabel(.done)
                            .padding(8).background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .onAppear { newFat = String(foodItem.fat) }
                    }
                }

                Button(action: onSave) {
                    Text("Speichern")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(20)
        }
        .background(.clear)
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    NavigationStack {
        AddTrackedFoodView(showAddTrackedFoodPanel: .constant(false), selectedDaytime: 0, selectedDate: Date())
            .environment(\.managedObjectContext, context)
            .environmentObject(MainViewModel(context: context))
            .environmentObject(AddTrackedFoodViewModel(context: context))
            .environmentObject(OpenFoodFactsViewModel(context: context))
            .environmentObject(CreateMealPanelViewModel(context: context))
            .environmentObject(BarCodeViewModel(context: context))
    }
}
