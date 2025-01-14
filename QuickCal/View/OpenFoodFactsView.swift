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
    @State private var showCustomAlert = false
    @State private var selectedFood: FoodItem?
    @State private var quantity: String = ""
    
    var selectedDaytime: Int
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .leading) {
                    List {
                        Section(header: Text("OpenFoodFacts").font(.subheadline)) {
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
                                    showCustomAlert = true // Trigger the custom alert
                                }
                            }
                        }
                        
                    }
                    .searchable(text: $textfield, placement: .navigationBarDrawer(displayMode: .always))
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
        .overlay(
            Group {
                if showCustomAlert {
                    CustomAlertOFF(
                        isPresented: $showCustomAlert,
                        quantity: $quantity,
                        foodItem: selectedFood, // Übergib das ausgewählte FoodItem
                        onSave: {
                            if let food = selectedFood, let quantityValue = Float(quantity.replacingOccurrences(of: ",", with: ".")) {
                                openFoodFactsViewModel.OpenFoodFactsFoodToDB(name: selectedFood?.name ?? "", defaultQuantity: selectedFood?.defaultQuantity ?? 0, unit: selectedFood?.unit ?? "g", calories: selectedFood?.kcal ?? 0, carbs: selectedFood?.carbohydrate ?? 0, protein: selectedFood?.protein ?? 0, fat: selectedFood?.fat ?? 0, daytime: Int16(selectedDaytime), quantity: quantityValue)
                                print("FoodItem \(food.name) mit Menge \(quantityValue) hinzugefügt!")
                                mainViewModel.updateData()
                                resetAlert()
                            }
                        },
                        onCancel: {
                            resetAlert()
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
}

struct CustomAlertOFF: View {
    @Binding var isPresented: Bool
    @Binding var quantity: String
    var foodItem: FoodItem? // Verwende FoodItem statt Food
    var onSave: () -> Void
    var onCancel: () -> Void
    
    private var portionAmount: Float {
        Float(quantity.replacingOccurrences(of: ",", with: ".")) ?? 1.0
    }
    
    var body: some View {
        if isPresented, let food = foodItem {
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Display the name of the selected food item
                    Text(food.name)
                        .font(.headline)
                        .padding(.top)
                    
                    // Display the default quantity of the food item
                    Text("Portionsgröße: \(String(format: "%.0f", food.defaultQuantity)) \(food.unit)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Quantity input field
                    TextField("Anzahl an Portionen: 1", text: $quantity)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .padding(.horizontal)
                    
                    Divider()
                    
                    Text("Kcal: \(String(format: "%.0f", Float(food.kcal) * portionAmount))")
                        .font(.subheadline)
                    
                    HStack {
                        Spacer()
                        Text("C: \(String(format: "%.1f", food.carbohydrate * portionAmount)) g")
                        Spacer()
                        Text("P: \(String(format: "%.1f", food.protein * portionAmount)) g")
                        Spacer()
                        Text("F: \(String(format: "%.1f", food.fat * portionAmount)) g")
                        Spacer()
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    Divider()
                    // Action buttons
                    HStack {
                        Button("Abbrechen") {
                            onCancel()
                        }
                        .padding()
                        
                        Button("Hinzufügen") {
                            onSave()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 10)
                .frame(maxWidth: 300)
            }
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    OpenFoodFactsView(selectedDaytime: 0)
        .environmentObject(OpenFoodFactsViewModel(context: context)) // Ensure the EnvironmentObject is provided
}
