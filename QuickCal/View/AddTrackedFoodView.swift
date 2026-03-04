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
    @EnvironmentObject var createMealPanelViewModel: CreateMealPanelViewModel
    @EnvironmentObject var barCodeViewModel: BarCodeViewModel
    var selectedDaytime: Int
    var selectedDate: Date
    
    @State private var searchText = ""
    @State private var quantity: String = ""
    @State private var selectedFood: Food?
    @State private var selectedMeal: Meal?
    @State private var editFood: Food?
    
    @State private var newName: String = ""
    @State private var newUnit: String = ""
    @State private var newDefaultQuantity: String = ""
    @State private var newCalories: String = ""
    @State private var newCarbs: String = ""
    @State private var newProtein: String = ""
    @State private var newFat: String = ""
    
    //State für FullScreenView
    @State private var showFullScreenBarCodeView = false
    @State private var showBarcodeScanner = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    //Lebensmittel
                    NavigationLink(destination: CreateFoodPanelView()) {
                        VStack {
                            Image(systemName: "carrot.fill")
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
                    
                    // Barcode Button
                    Button(action: {
                        showFullScreenBarCodeView.toggle()
                    }) {
                        VStack {
                            Image(systemName: "barcode")
                                .font(.title)
                                .padding(.bottom, 2)
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 30)
                    }
                    .buttonStyle(.bordered)
                    .fullScreenCover(isPresented: $showFullScreenBarCodeView) {
                        BarCodeView(selectedDaytime: selectedDaytime, selectedDate: selectedDate)
                    }
                    //                //Barcode
                    //                NavigationLink(destination: BarCodeView(selectedDaytime: selectedDaytime, selectedDate: selectedDate)) {
                    //                    VStack {
                    //                        Image(systemName: "barcode")
                    //                            .font(.title)
                    //                            .padding(.bottom, 2)
                    //                            .foregroundColor(.blue)
                    //                        //Text("Barcode")
                    //                            .font(.footnote)
                    //                            .foregroundColor(.primary)
                    //                    }
                    //                    .frame(maxWidth: .infinity, maxHeight: 30)
                    //
                    //                }
                    //                .buttonStyle(.bordered)
                    
                    
                }
                .padding(.horizontal)

                VStack(alignment: .leading) {
                    Picker("", selection: $selectedTab) {
                        Label("Lebensmittel", systemImage: "carrot.fill").tag(0)
                        Label("Gerichte", systemImage: "fork.knife").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.bottom, 4)

                    if selectedTab == 0 {
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
                                    .onLongPressGesture {
                                        editFood = food
                                    }
                                    .onTapGesture {
                                        selectedFood = food
                                    }
                                }
                                .onDelete { offsets in
                                    addTrackedFoodViewModel.deleteFoodItem(at: offsets)
                                    mainViewModel.updateData()
                                }
                            }
                        }
                        .listStyle(.grouped)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 5)
                    } else {
                        List {
                            Section(header: Text("Zuletzt benutzte Gerichte:")
                                .font(.subheadline)
                                .textCase(.none)
                            ) {
                                ForEach(addTrackedFoodViewModel.mealItems) { meal in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("\(meal.name ?? "Unbekannt")")
                                            Text("\(meal.defaultQuantity) \(meal.unit == "Portion" && meal.defaultQuantity > 1 ? "Portionen" : meal.unit ?? "")")
                                                .font(.footnote)
                                        }
                                        Spacer()
                                        Text("\(meal.kcal) kcal")
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedMeal = meal
                                    }
                                }
                                .onDelete(perform: addTrackedFoodViewModel.deleteMealItem)
                            }
                        }
                        .listStyle(.grouped)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 5)
                    }

                    Spacer()
                }
                .padding([.top, .leading, .trailing])
                .onAppear {
                    addTrackedFoodViewModel.fetchFoodItems()
                    addTrackedFoodViewModel.fetchMealItems()
                    createMealPanelViewModel.clearStruct()
                    
                }
                .onDisappear {
                    //barCodeViewModel.stopScanning()
                }
            }
            .navigationTitle("Hinzufügen")
            .searchable(text: $searchText)
            .onChange(of: searchText) { _, newValue in
                addTrackedFoodViewModel.filterFoodItems(by: newValue)
                addTrackedFoodViewModel.filterMealItems(by: newValue)
            }
        }
        
        .sheet(item: $selectedFood, onDismiss: { selectedFood = nil; quantity = "" }) { food in
            CustomFoodAlert(
                quantity: $quantity,
                foodItem: food,
                onSave: {
                    if let quantityValue = Float(quantity.replacingOccurrences(of: ",", with: ".")) {
                        addTrackedFoodViewModel.addTrackedFood(
                            food: food,
                            quantity: quantityValue,
                            daytime: Int16(selectedDaytime),
                            selectedDate: selectedDate
                        )
                        selectedFood = nil
                        mainViewModel.updateData()
                    }
                },
                onCancel: { selectedFood = nil }
            )
            .presentationDetents([.fraction(0.4)])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $selectedMeal, onDismiss: { selectedMeal = nil; quantity = "" }) { meal in
            CustomMealAlert(
                quantity: $quantity,
                mealItem: meal,
                onSave: {
                    if let quantityValue = Float(quantity.replacingOccurrences(of: ",", with: ".")) {
                        addTrackedFoodViewModel.addTrackedMeal(
                            meal: meal,
                            quantity: quantityValue,
                            daytime: Int16(selectedDaytime),
                            selectedDate: selectedDate
                        )
                        selectedMeal = nil
                        mainViewModel.updateData()
                    }
                },
                onCancel: { selectedMeal = nil }
            )
            .presentationDetents([.fraction(0.4)])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $editFood, onDismiss: { editFood = nil }) { food in
            CustomAlertEditFoodAttributes(
                newName: $newName,
                newUnit: $newUnit,
                newDefaultQuantity: $newDefaultQuantity,
                newCalories: $newCalories,
                newCarbs: $newCarbs,
                newProtein: $newProtein,
                newFat: $newFat,
                foodItem: food,
                onSave: {
                    addTrackedFoodViewModel.updateFoodItemAttributes(food: food, newName: newName, newUnit: newUnit, newDefaultQuantity: newDefaultQuantity, newCalories: newCalories, newCarbs: newCarbs, newProtein: newProtein, newFat: newFat)
                    editFood = nil
                    mainViewModel.updateData()
                },
                onCancel: { editFood = nil }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .scrollContentBackground(.hidden)
        }
    }
    
}

// CustomAlert mit modifizierter Mengenangabe, sowie automatischer Berechnung
struct CustomFoodAlert: View {
    @Binding var quantity: String
    var foodItem: Food
    var onSave: () -> Void
    var onCancel: () -> Void

    private var portionAmount: Float {
        Float(quantity.replacingOccurrences(of: ",", with: ".")) ?? 1.0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Header
            VStack(spacing: 4) {
                Text(foodItem.name ?? "Unbekannt")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("\(String(format: "%.0f", foodItem.defaultQuantity)) \(foodItem.unit ?? "") pro Portion")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            // Quantity input
            VStack(alignment: .leading, spacing: 6) {
                Text("Menge")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                TextField("1", text: $quantity)
                    .font(.title2)
                    .keyboardType(.decimalPad)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            // Macros
            HStack {
                Spacer()
                Text("Kcal: \(String(format: "%.0f", Float(foodItem.kcal) * portionAmount))")
                Spacer()
                Text("K: \(String(format: "%.1fg", foodItem.carbohydrate * portionAmount))")
                Spacer()
                Text("P: \(String(format: "%.1fg", foodItem.protein * portionAmount))")
                Spacer()
                Text("F: \(String(format: "%.1fg", foodItem.fat * portionAmount))")
                Spacer()
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            // Action button
            Button(action: onSave) {
                Text("Hinzufügen")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(20)
    }
}

// Selbiger Custom Alert nur fur Gerichte
struct CustomMealAlert: View {
    @Binding var quantity: String
    var mealItem: Meal
    var onSave: () -> Void
    var onCancel: () -> Void

    private var portionAmount: Float {
        Float(quantity.replacingOccurrences(of: ",", with: ".")) ?? Float(mealItem.defaultQuantity)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {

            // Header
            VStack(spacing: 4) {
                Text(mealItem.name ?? "Unbekannt")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("\(mealItem.defaultQuantity) \(mealItem.unit == "Portion" && mealItem.defaultQuantity > 1 ? "Portionen" : mealItem.unit ?? "") pro Portion")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            // Quantity input
            VStack(alignment: .leading, spacing: 8) {
                Text("Menge")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                TextField("1", text: $quantity)
                    .font(.title2)
                    .keyboardType(.decimalPad)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            // Ingredients
            if let mealFoods = mealItem.mealFood as? Set<MealFood> {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Zutaten")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    let foodNames = mealFoods.compactMap { $0.food?.name }.sorted()
                    Text(foodNames.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // Macros
            HStack {
                Spacer()
                Text("Kcal: \(String(format: "%.0f", Float(mealItem.kcal) / Float(mealItem.defaultQuantity) * portionAmount))")
                Spacer()
                Text("K: \(String(format: "%.1fg", mealItem.carbohydrate / Float(mealItem.defaultQuantity) * portionAmount))")
                Spacer()
                Text("P: \(String(format: "%.1fg", mealItem.protein / Float(mealItem.defaultQuantity) * portionAmount))")
                Spacer()
                Text("F: \(String(format: "%.1fg", mealItem.fat / Float(mealItem.defaultQuantity) * portionAmount))")
                Spacer()
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            // Action button
            Button(action: onSave) {
                Text("Hinzufügen")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
    }
}

//Custom Alert um bei Longpress Eintrag zu Bearbeiten
struct CustomAlertEditFoodAttributes: View {
    @Binding var newName: String
    @Binding var newUnit: String
    @Binding var newDefaultQuantity: String
    @Binding var newCalories: String
    @Binding var newCarbs: String
    @Binding var newProtein: String
    @Binding var newFat: String
    var foodItem: Food
    var onSave: () -> Void
    var onCancel: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 11) {

                // Header
                Text("Bearbeiten")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)

                // Name
                VStack(alignment: .leading, spacing: 6) {
                    Text("Name")
                        .font(.caption).foregroundStyle(.secondary).textCase(.uppercase)
                    TextField("Neuer Name", text: $newName)
                        .submitLabel(.done)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .onAppear { newName = foodItem.name ?? "" }
                }

                // Portionsgröße + Einheit
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Portionsgröße")
                            .font(.caption).foregroundStyle(.secondary).textCase(.uppercase)
                        TextField("100", text: $newDefaultQuantity)
                            .keyboardType(.numberPad)
                            .submitLabel(.done)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .onAppear { newDefaultQuantity = String(foodItem.defaultQuantity) }
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Einheit")
                            .font(.caption).foregroundStyle(.secondary).textCase(.uppercase)
                        Picker("Einheit", selection: $newUnit) {
                            Text("Gramm").tag("g")
                            Text("Kilogramm").tag("kg")
                            Text("Milliliter").tag("ml")
                            Text("Liter").tag("l")
                            Text("Stück").tag("Stück")
                        }
                        .pickerStyle(.menu)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .onAppear { newUnit = foodItem.unit ?? "g" }
                    }
                }

                // Kalorien
                VStack(alignment: .leading, spacing: 6) {
                    Text("Kalorien (kcal)")
                        .font(.caption).foregroundStyle(.secondary).textCase(.uppercase)
                    TextField("83", text: $newCalories)
                        .keyboardType(.decimalPad)
                        .submitLabel(.done)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .onAppear { newCalories = String(foodItem.kcal) }
                }

                // Kohlenhydrate / Protein / Fett
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("K (g)")
                            .font(.caption).foregroundStyle(.secondary).textCase(.uppercase)
                        TextField("43", text: $newCarbs)
                            .keyboardType(.decimalPad)
                            .submitLabel(.done)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .onAppear { newCarbs = String(foodItem.carbohydrate) }
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("P (g)")
                            .font(.caption).foregroundStyle(.secondary).textCase(.uppercase)
                        TextField("5.1", text: $newProtein)
                            .keyboardType(.decimalPad)
                            .submitLabel(.done)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .onAppear { newProtein = String(foodItem.protein) }
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("F (g)")
                            .font(.caption).foregroundStyle(.secondary).textCase(.uppercase)
                        TextField("1.3", text: $newFat)
                            .keyboardType(.decimalPad)
                            .submitLabel(.done)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .onAppear { newFat = String(foodItem.fat) }
                    }
                }

                // Save button
                Button(action: onSave) {
                    Text("Speichern")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(20)
        }
        .background(.clear)
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    AddTrackedFoodView(showAddTrackedFoodPanel: .constant(false), selectedDaytime: 0, selectedDate: Date())
        .environment(\.managedObjectContext, context)
        .environmentObject(MainViewModel(context: context))
        .environmentObject(AddTrackedFoodViewModel(context: context))
        .environmentObject(OpenFoodFactsViewModel(context: context))
        .environmentObject(CreateMealPanelViewModel(context: context))
        .environmentObject(BarCodeViewModel(context: context))
}
