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
    @EnvironmentObject var mainViewModel: MainViewModel
    var selectedDaytime: Int
    
    @State private var searchText = ""
    @State private var showCustomAlert = false
    @State private var quantity: String = ""
    @State private var selectedDaytimeString: String = "Morning"
    @State private var selectedFood: Food?
    

    
    var body: some View {
        NavigationStack {
            HStack {
                NavigationLink(destination: CreatePanelView()) {
                    VStack {
                        Text("+")
                            .font(.largeTitle)
                        Text("Lebensmittel")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                }
                .buttonStyle(.bordered)
                .padding(.leading)
                Button(action: {
                    // Aktion hier
                }) {
                    VStack {
                        Text("+")
                            .font(.largeTitle)
                        Text("Gericht")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)

                }
                .padding(.trailing)
                .buttonStyle(.bordered)            }
            
            VStack(alignment: .leading) {
                List {
                    Section(header: Text("Lebensmittel").font(.subheadline)) { // Titel der Liste
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
                }
                .listStyle(.grouped)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 5)
                
                Spacer()
                Spacer()
                Spacer()
                List {
                    Section(header:
                                Text("Gerichte").font(.subheadline)) {
                        Text("Dummy")
                    }
                    
                }
                .listStyle(.grouped)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 5)
            }
            .padding()
            .onAppear {
                addTrackedFoodViewModel.fetchFoodItems()
            }
            
            .textCase(.none)
            .searchable(text: $searchText)
            
        }
        .overlay(
            CustomAlert(
                isPresented: $showCustomAlert,
                quantity: $quantity,
                foodItem: selectedFood, // Übergebe das gesamte Food-Objekt
                onSave: {
                    if let food = selectedFood, let quantityValue = Float(quantity.replacingOccurrences(of: ",", with: ".")) {
                        addTrackedFoodViewModel.addTrackedFood(
                            food: food,
                            quantity: quantityValue,
                            daytime: Int16(selectedDaytime)
                        )
                        resetAlert()
                        mainViewModel.updateData()
                    }
                },
                onCancel: {
                    resetAlert()
                }
            )
        )
    }
    
    
    private func resetAlert() {
        selectedFood = nil
        quantity = ""
        selectedDaytimeString = "Morning"
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
        Float(quantity.replacingOccurrences(of: ",", with: ".")) ?? 1.0
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
    AddTrackedFoodView(showAddTrackedFoodPanel: .constant(false), selectedDaytime: 0)
        .environment(\.managedObjectContext, context)
        .environmentObject(AddTrackedFoodViewModel(context: context))
}
