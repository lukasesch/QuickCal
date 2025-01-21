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
    var selectedDate: Date
    
    @State private var searchText = ""
    @State private var showCustomAlert = false
    @State private var quantity: String = ""
    @State private var selectedFood: Food?
    @State private var selectedMeal: Meal?
    
    // State für FullScreen-View
    @State private var showBarcodeScanner = false
    
    var body: some View {
        NavigationStack {
            HStack {
                //Lebensmittel
                NavigationLink(destination: CreateFoodPanelView()) {
                    VStack {
                        Image(systemName: "leaf.fill")
                            .font(.title3)
                            .padding(.bottom, 2)
                            .foregroundColor(.blue)
                        //Text("Lebensmittel")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 30)
                }
                .buttonStyle(.bordered)
                
                //Gerichte
                NavigationLink(destination: CreateMealPanelView()) {
                    VStack {
                        Image(systemName: "fork.knife")
                            .font(.title3)
                            .padding(.bottom, 2)
                            .foregroundColor(.blue)
                        //Text("Lebensmittel")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 30)
                }
                .buttonStyle(.bordered)
                
                //OpenFoodFacts
                NavigationLink(destination: OpenFoodFactsView(selectedDaytime: selectedDaytime, selectedDate: selectedDate)) {
                    VStack {
                        Image(systemName: "tray.and.arrow.down.fill")
                            .font(.title3)
                            .padding(.bottom, 2)
                            .foregroundColor(.blue)
                        //Text("OpenFoodFacts")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 30)
                }
                .buttonStyle(.bordered)
                
                //Barcode
                NavigationLink(destination: BarCodeView(selectedDaytime: selectedDaytime, selectedDate: selectedDate)) {
                    VStack {
                        Image(systemName: "barcode")
                            .font(.title)
                            .padding(.bottom, 2)
                            .foregroundColor(.blue)
                        //Text("Barcode")
                            .font(.footnote)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 30)
                    
                }
                .buttonStyle(.bordered)
                
                
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading) {
                TabView {
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
                    .tabItem {
                        Label("Lebensmittel", systemImage: "leaf")
                    }
                    
                    List {
                        Section(header: Text("Zuletzt benutzte Gerichte:")
                            .font(.subheadline)
                            .textCase(.none)
                        ) {
                            ForEach(addTrackedFoodViewModel.mealItems) { meal in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("\(meal.name ?? "Unbekannt")")
                                        Text("\(String(format: "%.0f", meal.defaultQuantity)) \(meal.unit ?? "")")
                                            .font(.footnote)
                                    }
                                    Spacer()
                                    Text("\(meal.kcal) kcal")
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedMeal = meal
                                    showCustomAlert = true // Trigger the custom alert
                                }
                            }
                            .onDelete(perform: addTrackedFoodViewModel.deleteFoodItem)
                        }
                        
                    }
                    .tabItem {
                        Label("Gerichte", systemImage: "fork.knife")
                    }
                    
                }

                
                
                .listStyle(.grouped)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 5)
            
                Spacer()
                Spacer()
                Spacer()

            }
            .padding([.top, .leading, .trailing])
            .onAppear {
                addTrackedFoodViewModel.fetchFoodItems()
            }
            
//            .searchable(text: $searchText)
//            .onChange(of: searchText) {
//                addTrackedFoodViewModel.filterFoodItems(by: searchText)
//            }
//            .onSubmit(of: .search) {
//                openFoodFactsViewModel.search(text: searchText)
//            }
            
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
                                    daytime: Int16(selectedDaytime),
                                    selectedDate: selectedDate
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
        .searchable(text: $searchText)
        .onChange(of: searchText) {
            addTrackedFoodViewModel.filterFoodItems(by: searchText)
        }
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
    AddTrackedFoodView(showAddTrackedFoodPanel: .constant(false), selectedDaytime: 0, selectedDate: Date())
        .environment(\.managedObjectContext, context)
        .environmentObject(MainViewModel(context: context))
        .environmentObject(AddTrackedFoodViewModel(context: context))
        .environmentObject(OpenFoodFactsViewModel(context: context))
}
