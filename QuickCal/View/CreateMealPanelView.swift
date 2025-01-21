//
//  CreateMealPanelView.swift
//  QuickCal
//
//  Created by Lukas Esch on 20.01.25.
//

import SwiftUI

struct CreateMealPanelView: View {
    @EnvironmentObject var createMealPanelViewModel: CreateMealPanelViewModel
    @State private var nameTF = ""
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    
    enum Field: Int, CaseIterable {
        case name
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Neues Gericht:")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                Divider()
                HStack {
                    Text("Name:")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Spacer() // Füllt den verfügbaren Platz zwischen den Texten
                    TextField("z.B. Spaghetti Bolognese", text: $nameTF)
                        .font(.headline)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.trailing)
                        .submitLabel(.done)
                        .focused($focusedField, equals: .name)
                        .padding(.vertical, 5.0)
                        .padding(.trailing, 16.0)
                }
                Divider()
                List {
                    Section {
                        ForEach(createMealPanelViewModel.mealFoods) { mealFood in
                            let food = mealFood.food
                            let kcal = food.kcal
                            let defaultQuantity = food.defaultQuantity
                            let unit = food.unit ?? ""
                            let quantity = mealFood.quantity
                            let totalkcal = Float(kcal) * quantity
                            let displayQuantity = quantity * defaultQuantity
                            
                            // Render the food item
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(food.name ?? "Unknown Food")
                                            Text("\(String(format: "%.0f", displayQuantity)) \(unit)")
                                                .font(.footnote)
                                        }
                                        Spacer()
                                        Text("\(String(format: "%.0f", totalkcal)) kcal") // Kalorien
                                    }
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .onDelete { offsets in
                            createMealPanelViewModel.deleteIngredient(at: offsets)
                        }
                    } header: {
                        VStack {
                            HStack {
                                Text("Zutaten des Gerichts")
                                    .fontWeight(.semibold)
                                Spacer()
                                NavigationLink(destination: CreateMealIngredientsView()) {
                                    Image(systemName: "plus")
                                        .fontWeight(.semibold)
                                }
                            }
                            Divider()
                            HStack {
                                Text("Kcal: \(String(format: "%.0f", createMealPanelViewModel.kcalTotal))")
                                Spacer()
                                Text("C: \(String(format: "%.0f", createMealPanelViewModel.carbsTotal)) g")
                                Spacer()
                                Text("P: \(String(format: "%.0f", createMealPanelViewModel.proteinTotal)) g")
                                Spacer()
                                Text("F: \(String(format: "%.0f", createMealPanelViewModel.fatTotal)) g")
                                Spacer()
                            }
                            .font(.footnote)
                        }
                    }
                }
                .listStyle(.grouped)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.top)
                .shadow(radius: 5)
                
                
                HStack {
                    Button(action: {
                        dismiss()
                        
                    }) {
                        Text("Erstellen")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.bold)
                            .padding()
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Abbrechen")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.bold)
                            .padding()
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                }
                .padding(.top)
            }
            .padding()
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    CreateMealPanelView()
        .environmentObject(CreateMealPanelViewModel())
        .environment(\.managedObjectContext, context)
        .environmentObject(AddTrackedFoodViewModel(context: context))
}
