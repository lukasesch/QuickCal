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
        VStack(alignment: .leading) {
            HStack {
                Text("Suchleiste")
                Spacer()
                Text("+")
            }
            Divider()
            Spacer()
            
            Text("Liste der letzten Lebensmittel")
                .font(.headline)
                .padding(.bottom, 5)
            
            List {
                ForEach(addTrackedFoodViewModel.foodItems) { food in
                    HStack {
                        Text(food.name ?? "Unbekannt")
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
            //.padding()
            .shadow(radius: 5)
            
            
            Spacer()
            Divider()
            Spacer()
            Text("Liste der letzten Gerichte")
                .font(.headline)
            Spacer()
        }
        .padding()
        .onAppear {
            addTrackedFoodViewModel.fetchFoodItems()
        }
        .overlay(
            CustomAlert(
                isPresented: $showCustomAlert,
                quantity: $quantity,
                foodName: selectedFood?.name ?? "Unknown Food",
                defaultQuantity: Double(selectedFood?.defaultQuantity ?? 0),
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
    var foodName: String
    var defaultQuantity: Double
    var onSave: () -> Void
    var onCancel: () -> Void
    
    var body: some View {
        if isPresented {
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Display the name of the selected food item
                    Text(foodName)
                        .font(.headline)
                        .padding(.top)
                    
                    // Display the default quantity of the food item
                    Text("Default Quantity: \(String(format: "%.0f", defaultQuantity)) g")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Quantity input field
                    TextField("Enter Quantity", text: $quantity)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .padding(.horizontal)
                    
                    // Action buttons
                    HStack {
                        Button("Cancel") {
                            onCancel()
                        }
                        .padding()
                        
                        Button("Save") {
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
