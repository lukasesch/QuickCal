//
//  AddTrackedFoodView.swift
//  QuickCal
//
//  Created by Lukas Esch on 05.11.24.
//

import SwiftUI
import CoreData

struct AddTrackedFoodView: View {
    @Binding var showAddTrackedFoodPanel: Bool
    @EnvironmentObject var addTrackedFoodViewModel: AddTrackedFoodViewModel
    
    
    @State private var showCustomAlert = false
    @State private var quantity: String = ""
    @State private var selectedDaytime: String = "Morning"
    @State private var selectedFood: Food?

    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("Lebensmittel")
                        .font(.headline)
                        .padding(.bottom, 5)
                    Spacer()
                    NavigationLink(destination: CreatePanelView()) {
                        Image(systemName: "plus")
                    }
                }
                Text("Suchleiste")
                List {
                    ForEach(addTrackedFoodViewModel.foodItems) { food in
                        HStack {
                            Text("\(food.name ?? "Unbekannt"), \(String(format: "%.0f", food.defaultQuantity)) \(food.unit ?? "")")
                            Spacer()
                            Text("\(food.kcal) kcal")
                        }
                        .onTapGesture {
                            selectedFood = food
                            showCustomAlert = true // Trigger the custom alert
                        }
                    }
                    .onDelete(perform: addTrackedFoodViewModel.deleteFoodItem)
                }
                .listStyle(.grouped)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 5)
                
                Spacer()
                Spacer()
                Divider()
                Spacer()
                HStack {
                    Text("Gerichte")
                        .font(.headline)
                        .padding(.bottom, 5)
                    Spacer()
                    Text("+")
                }
                Text("Suchleiste")
                List {
                    
                }
            }
            .padding()
            .onAppear {
                addTrackedFoodViewModel.fetchFoodItems()
            }
            .overlay(
                CustomAlert(
                    isPresented: $showCustomAlert,
                    quantity: $quantity,
                    foodItem: selectedFood, // Übergebe das gesamte Food-Objekt
                    onSave: {
                        if let food = selectedFood, let quantityValue = Double(quantity) {
                            addTrackedFoodViewModel.addTrackedFood(
                                food: food,
                                quantity: Float(quantityValue),
                                daytime: 0
                            )
                            resetAlert()
                        }
                    },
                    onCancel: {
                        resetAlert()
                    }
                )
            )
            .textCase(.none)
        }
    }
    
    
    private func resetAlert() {
        selectedFood = nil
        quantity = ""
        selectedDaytime = "Morning"
        showCustomAlert = false
    }
}

// Custom alert view with fields for quantity input and displays food name and default quantity
struct CustomAlert: View {
    @Binding var isPresented: Bool
    @Binding var quantity: String
    var foodItem: Food? // Übergebe das gesamte Food-Objekt
    var onSave: () -> Void
    var onCancel: () -> Void
    
    private var portionAmount: Float {
        Float(quantity) ?? 1.0
    }
    
    var body: some View {
        if isPresented, let food = foodItem {
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Display the name of the selected food item
                    Text(food.name ?? "Unbekannt")
                        .font(.headline)
                        .padding(.top)
                    
                    // Display the default quantity of the food item
                    Text("Portionsgröße: \(String(format: "%.0f", food.defaultQuantity)) \(food.unit ?? "")")
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
    AddTrackedFoodView(showAddTrackedFoodPanel: .constant(false))
        .environment(\.managedObjectContext, context)
        .environmentObject(AddTrackedFoodViewModel(context: context))
}
