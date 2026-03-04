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
                                Text("\(String(format: "%.1f", food.defaultQuantity)) \(food.unit ?? "")")
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
            .searchable(text: $searchText)
            .onChange(of: searchText) { _, newValue in
                addTrackedFoodViewModel.filterFoodItems(by: newValue)
            }
        }
        .sheet(item: $selectedFood, onDismiss: { selectedFood = nil; quantity = "" }) { food in
            CustomFoodAlert(
                quantity: $quantity,
                foodItem: food,
                onSave: {
                    if let quantityValue = Float(quantity.replacingOccurrences(of: ",", with: ".")) {
                        createMealPanelViewModel.addIngredient(food: food, quantity: quantityValue)
                        selectedFood = nil
                        dismiss()
                    }
                },
                onCancel: { selectedFood = nil }
            )
            .presentationDetents([.fraction(0.4)])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    CreateMealIngredientsView()
        .environment(\.managedObjectContext, context)
        .environmentObject(AddTrackedFoodViewModel(context: context))
        .environmentObject(CreateMealPanelViewModel(context: context))
}
