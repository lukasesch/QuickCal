//
//  OpenFoodFactsView.swift
//  QuickCal
//
//  Created by Lukas Esch on 17.11.24.
//

import SwiftUI

struct OpenFoodFactsView: View {
    @Binding var showAddTrackedFoodPanel: Bool
    @EnvironmentObject var openFoodFactsViewModel: OpenFoodFactsViewModel
    @EnvironmentObject var mainViewModel: MainViewModel
    @EnvironmentObject var barCodeViewModel: BarCodeViewModel

    @Environment(\.dismiss) private var dismiss

    var selectedDaytime: Int
    var selectedDate: Date
    var initialQuery: String = ""

    @State private var searchText: String = ""
    @State private var searchFocused: Bool = false
    @State private var selectedFood: FoodItem?
    @State private var quantity: String = ""
    @State private var showFullScreenBarCodeView = false

    private var p: MealPreset { mealPreset(selectedDaytime) }

    var body: some View {
        ZStack(alignment: .bottom) {
            LiquidBackdrop()

            ScrollView {
                VStack(spacing: 0) {
                    header

                    content
                        .padding(.horizontal, 16)

                    Spacer().frame(height: 130)
                }
                .padding(.top, 6)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)

            BottomSearchDock(
                text: $searchText,
                focused: $searchFocused,
                placeholder: "OpenFoodFacts durchsuchen",
                onSubmit: { openFoodFactsViewModel.search(text: searchText) },
                onScan: { showFullScreenBarCodeView = true }
            )
            .padding(.bottom, 12)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if !initialQuery.isEmpty && searchText.isEmpty {
                searchText = initialQuery
                openFoodFactsViewModel.search(text: initialQuery)
            }
        }
        .fullScreenCover(isPresented: $showFullScreenBarCodeView) {
            BarCodeView(selectedDaytime: selectedDaytime, selectedDate: selectedDate)
        }
        .sheet(item: $selectedFood, onDismiss: { selectedFood = nil; quantity = "" }) { food in
            portionSheet(for: food)
        }
    }

    @ViewBuilder
    private func portionSheet(for food: FoodItem) -> some View {
        let subtitle = "\(formatNum(food.defaultQuantity)) \(food.unit) pro Portion"
        let ctaLabel = "Zu \(p.label) hinzufügen"
        PortionSheet(
            title: food.name,
            subtitle: subtitle,
            isFood: true,
            headerIcon: "carrot.fill",
            baseDefault: food.defaultQuantity,
            unit: food.unit,
            baseKcal: Float(food.kcal),
            baseCarbs: food.carbohydrate,
            baseProtein: food.protein,
            baseFat: food.fat,
            tint: p.tint,
            ctaLabel: ctaLabel,
            ctaIcon: p.icon,
            quantity: $quantity,
            onSave: { saveFood(food) },
            onCancel: { selectedFood = nil }
        )
        .presentationDetents([.fraction(0.55), .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(.regularMaterial)
    }

    private func saveFood(_ food: FoodItem) {
        let ok = openFoodFactsViewModel.addToTracker(
            item: food,
            quantityString: quantity,
            daytime: Int16(selectedDaytime),
            date: selectedDate
        )
        guard ok else { return }
        mainViewModel.updateData()
        selectedFood = nil
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            HStack {
                CircleGlassButton(systemName: "chevron.left") {
                    dismiss()
                }
                Spacer()
                CircleGlassButton(systemName: "checkmark") {
                    showAddTrackedFoodPanel = false
                    dismiss()
                }
            }
            Text("Open Food Facts")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(QC.fg)
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 10)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if openFoodFactsViewModel.isLoading {
            VStack(spacing: 14) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding(.top, 40)
                Text("Laden…")
                    .font(.system(size: 13))
                    .foregroundStyle(QC.fg2)
                Button {
                    openFoodFactsViewModel.cancelSearch()
                    searchText = ""
                } label: {
                    Text("Abbrechen")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(QC.blue)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(
                            Capsule().fill(QC.blue.opacity(0.10))
                                .overlay(Capsule().stroke(QC.blue.opacity(0.28), lineWidth: 0.5))
                        )
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        } else if openFoodFactsViewModel.products.isEmpty {
            VStack(spacing: 6) {
                Text(searchText.isEmpty ? "Suche starten" : "Keine Treffer")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(QC.fg)
                Text(searchText.isEmpty
                     ? "Begriff eingeben und Suche absenden."
                     : "Anderen Begriff probieren.")
                    .font(.system(size: 12))
                    .foregroundStyle(QC.fg3)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
        } else {
            let products = openFoodFactsViewModel.products
            VStack(spacing: 0) {
                ForEach(products.indices, id: \.self) { idx in
                    productRow(products[idx], isLast: idx == products.count - 1)
                }
            }
            .background(GlassCardBg())
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    @ViewBuilder
    private func productRow(_ food: FoodItem, isLast: Bool) -> some View {
        ResultRow(
            name: food.name,
            portion: "\(formatNum(food.defaultQuantity)) \(food.unit)",
            kcal: Int(food.kcal),
            carbs: food.carbohydrate,
            protein: food.protein,
            fat: food.fat,
            isLast: isLast
        )
        .contentShape(Rectangle())
        .onTapGesture {
            quantity = ""
            selectedFood = food
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    NavigationStack {
        OpenFoodFactsView(showAddTrackedFoodPanel: .constant(true), selectedDaytime: 0, selectedDate: Date())
            .environmentObject(OpenFoodFactsViewModel(context: context))
            .environmentObject(MainViewModel(context: context))
            .environmentObject(BarCodeViewModel(context: context))
    }
}
