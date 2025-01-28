//
//  CreateMealIngredientsView.swift
//  QuickCal
//
//  Created by Lukas Esch on 21.01.25.
//

import SwiftUI

struct CreateMealIngredientsView: View {
    @EnvironmentObject var addTrackedFoodViewModel: AddTrackedFoodViewModel
    @EnvironmentObject var createMealPanelViewModel: CreateMealPanelViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @State private var showCustomAlert = false
    @State private var quantity: String = ""
    @State private var selectedFood: Food?
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Zuletzt benutzte Lebensmittel:")
                    .font(.subheadline)
                    .textCase(.none)
                ) {
                    ForEach(addTrackedFoodViewModel.foodItems) { food in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(food.name ?? "Unbekannt")")
                                Text("\(String(format: "%.0f", food.defaultQuantity)) \(food.unit ?? "")")
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
                    .onDelete(perform: addTrackedFoodViewModel.deleteFoodItem)
                }
            }
            .listStyle(.grouped)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 5)
            
            .padding(.horizontal)
            .onAppear {
                addTrackedFoodViewModel.fetchFoodItems()
            }
//            .searchable(text: $searchText)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode:.always)
            )
            .onChange(of: searchText) {
                addTrackedFoodViewModel.filterFoodItems(by: searchText)
            }
        }
        .overlay(
            Group {
                if showCustomAlert {
                    CustomFoodAlert(
                        isPresented: $showCustomAlert,
                        quantity: $quantity,
                        foodItem: selectedFood,
                        onSave: {
                            if let food = selectedFood, let quantityValue = Float(quantity.replacingOccurrences(of: ",", with: ".")) {
                                createMealPanelViewModel.addIngredient(food: food, quantity: quantityValue)
                                resetAlert()
                                dismiss()
                            }
                        },
                        onCancel: {
                            resetAlert()
                        }
                    )
                    .transition(.opacity) // Transition hinzufügen
                }
            }
        )
        
        .animation(.easeInOut(duration: 0.2), value: showCustomAlert) // Animation aktivieren
        
    }
    
    private func resetAlert() {
        withAnimation {
            showCustomAlert = false
        }
        selectedFood = nil
        quantity = ""
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    CreateMealIngredientsView()
        .environment(\.managedObjectContext, context)
        .environmentObject(AddTrackedFoodViewModel(context: context))
        .environmentObject(CreateMealPanelViewModel(context: context))
}
