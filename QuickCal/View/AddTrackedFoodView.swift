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
    @EnvironmentObject var openFoodFactsViewModel: OpenFoodFactsViewModel
    var selectedDaytime: Int
    
    @State private var searchText = ""
    @State private var showCustomAlert = false
    @State private var quantity: String = ""
    @State private var selectedFood: Food?
    
    // State für FullScreen-View
    @State private var showBarcodeScanner = false
    
    var body: some View {
        NavigationStack {
            HStack {
                NavigationLink(destination: CreatePanelView()) {
                    VStack {
                        Image(systemName: "plus")
                            .font(.title3)
                            .padding(.bottom, 2)
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
                        Image(systemName: "plus")
                            .font(.title3)
                            .padding(.bottom, 2)
                        Text("Gericht")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    
                }
                .padding(.trailing)
                .buttonStyle(.bordered)
            }
            HStack {
                NavigationLink(destination: OpenFoodFactsView(selectedDaytime: selectedDaytime)) {
                    VStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3)
                            .padding(.bottom, 2)
                        Text("OpenFoodFacts")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                }
                .padding(.leading)
                .buttonStyle(.bordered)
                
                NavigationLink(destination: BarCodeView(selectedDaytime: selectedDaytime)) {
                    VStack {
                        Image(systemName: "barcode")
                            .font(.title)
                            .padding(.bottom, 3)
                        Text("Barcode")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                }
                .buttonStyle(.bordered)
                .padding(.trailing)
            }
            
            VStack(alignment: .leading) {
                List {
                    Section(header: Text("Zuletzt benutzte Lebensmittel:")
                        .font(.subheadline)
                        .textCase(.none)
                    ) {
                        ForEach(addTrackedFoodViewModel.foodItems) { food in
                            HStack {
                                Text("\(food.name ?? "Unbekannt"), \(String(format: "%.0f", food.defaultQuantity)) \(food.unit ?? "")")
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
            
                Spacer()
                Spacer()
                Spacer()
//                List {
//                    Section(header:
//                                Text("Gerichte").font(.subheadline)) {
//                        ForEach(openFoodFactsViewModel.products) { product in
//                            HStack {
//                                Text("\(product.name), \(String(format: "%.0f", product.defaultQuantity)) \(product.unit)")
//                                Spacer()
//                                Text("\(product.kcal) kcal")
//                            }
//                            .contentShape(Rectangle())
//                        }
//                    }
//                    
//                }
//                .listStyle(.grouped)
//                .clipShape(RoundedRectangle(cornerRadius: 10))
//                .shadow(radius: 5)
            }
            .padding([.top, .leading, .trailing])
            .onAppear {
                addTrackedFoodViewModel.fetchFoodItems()
            }
            
            .searchable(text: $searchText)
            .onChange(of: searchText) {
                addTrackedFoodViewModel.filterFoodItems(by: searchText)
            }
            .onSubmit(of: .search) {
                openFoodFactsViewModel.search(text: searchText)
            }
            
        }
        .overlay(
            Group {
                if showCustomAlert {
                    CustomAlert(
                        isPresented: $showCustomAlert,
                        quantity: $quantity,
                        foodItem: selectedFood,
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
        .environmentObject(OpenFoodFactsViewModel(context: context))
}
