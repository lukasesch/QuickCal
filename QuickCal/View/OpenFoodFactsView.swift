//
//  OpenFoodFactsView.swift
//  QuickCal
//
//  Created by Lukas Esch on 17.11.24.
//

import SwiftUI

struct OpenFoodFactsView: View {
    @EnvironmentObject var openFoodFactsViewModel: OpenFoodFactsViewModel
    @EnvironmentObject var mainViewModel: MainViewModel
    
    @State var textfield: String = ""
    @State private var selectedFood: FoodItem?
    @State private var quantity: String = ""
    
    var selectedDaytime: Int
    var selectedDate: Date
    
    @ViewBuilder private var navigationContent: some View {
        VStack {
            VStack(alignment: .leading) {
                if openFoodFactsViewModel.isLoading {
                    VStack {
                        ProgressView("Laden...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                        Button(action: {
                            openFoodFactsViewModel.isLoading = false
                            openFoodFactsViewModel.products.removeAll()
                            textfield = ""
                        }) {
                            Text("Abbrechen")
                                .foregroundColor(.gray)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        .padding(.top, -10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        Section(header: Text("Import von OpenFoodFacts").font(.subheadline)) {
                            ForEach(openFoodFactsViewModel.products) { food in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("\(food.name)")
                                        Text("\(food.defaultQuantity, specifier: "%.0f") \(food.unit)")
                                            .font(.footnote)
                                    }
                                    Spacer()
                                    Text("\(food.kcal) kcal")
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedFood = food
                                }
                            }
                        }
                    }
                    .searchable(text: $textfield)
                    .onSubmit(of: .search) {
                        openFoodFactsViewModel.search(text: textfield)
                    }
                    .listStyle(.grouped)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 5)
                    .textCase(.none)
                    .padding()
                }
            }
        }
        .navigationTitle("Open Food Facts")
    }

    var body: some View {
        NavigationStack {
            if #available(iOS 18.0, *) {
                navigationContent.containerBackground(.clear, for: .navigation)
            } else {
                navigationContent
            }
        }
        .sheet(item: $selectedFood, onDismiss: { selectedFood = nil; quantity = "" }) { food in
            CustomAlertOFF(
                quantity: $quantity,
                foodItem: food,
                onSave: {
                    if let quantityValue = Float(quantity.replacingOccurrences(of: ",", with: ".")) {
                        openFoodFactsViewModel.OpenFoodFactsFoodToDB(name: food.name, defaultQuantity: food.defaultQuantity, unit: food.unit, calories: food.kcal, carbs: food.carbohydrate, protein: food.protein, fat: food.fat, daytime: Int16(selectedDaytime), quantity: quantityValue, selectedDate: selectedDate)
                        mainViewModel.updateData()
                        selectedFood = nil
                    }
                },
                onCancel: { selectedFood = nil }
            )
            .presentationDetents([.fraction(0.4)])
            .presentationDragIndicator(.visible)
        }
    }
}

struct CustomAlertOFF: View {
    @Binding var quantity: String
    var foodItem: FoodItem
    var onSave: () -> Void
    var onCancel: () -> Void

    private var portionAmount: Float {
        Float(quantity.replacingOccurrences(of: ",", with: ".")) ?? 1.0
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(foodItem.name)
                .font(.headline)
                .padding(.top)

            Text("Portionsgröße: \(String(format: "%.1f", foodItem.defaultQuantity)) \(foodItem.unit)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            TextField("Anzahl an Portionen: 1", text: $quantity)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .padding(.horizontal)

            Divider()

            Text("Kcal: \(String(format: "%.0f", Float(foodItem.kcal) * portionAmount))")
                .font(.subheadline)

            HStack {
                Spacer()
                Text("K: \(String(format: "%.1f", foodItem.carbohydrate * portionAmount)) g")
                Spacer()
                Text("P: \(String(format: "%.1f", foodItem.protein * portionAmount)) g")
                Spacer()
                Text("F: \(String(format: "%.1f", foodItem.fat * portionAmount)) g")
                Spacer()
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            Divider()

            HStack {
                Button("Abbrechen") { onCancel() }
                    .padding()
                Button("Hinzufügen") { onSave() }
                    .buttonStyle(.borderedProminent)
                    .padding()
            }
        }
        .padding()
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    OpenFoodFactsView(selectedDaytime: 0, selectedDate: Date())
        .environmentObject(OpenFoodFactsViewModel(context: context))
}
