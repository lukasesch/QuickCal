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
    var selectedDaytime: Int
    var selectedDate: Date
    
    @State private var searchText = ""
    @State private var showCustomFoodAlert = false
    @State private var showCustomMealAlert = false
    @State private var showCustomAlertEditAttributes = false
    @State private var quantity: String = ""
    @State private var selectedFood: Food?
    @State private var selectedMeal: Meal?
    
    @State private var newName: String = ""
    @State private var newUnit: String = ""
    @State private var newDefaultQuantity: String = ""
    @State private var newCalories: String = ""
    @State private var newCarbs: String = ""
    @State private var newProtein: String = ""
    @State private var newFat: String = ""

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
                                .onLongPressGesture {
                                    selectedFood = food
                                    withAnimation {
                                        showCustomAlertEditAttributes = true
                                    }
                                }
                                .onTapGesture {
                                    selectedFood = food
                                    showCustomFoodAlert = true // Trigger the custom alert
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
                                        Text("\(meal.defaultQuantity) \(meal.unit == "Portion" && meal.defaultQuantity > 1 ? "Portionen" : meal.unit ?? "")")
                                            .font(.footnote)
                                    }
                                    Spacer()
                                    Text("\(meal.kcal) kcal")
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedMeal = meal
                                    showCustomMealAlert = true // Trigger the custom alert
                                }
                            }
                            .onDelete(perform: addTrackedFoodViewModel.deleteMealItem)
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
                addTrackedFoodViewModel.fetchMealItems()
                createMealPanelViewModel.clearStruct()
            }
            .navigationTitle("Hinzufügen")
        }
        
        .overlay(
            Group {
                if showCustomFoodAlert {
                    CustomFoodAlert(
                        isPresented: $showCustomFoodAlert,
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
                    .animation(.easeInOut(duration: 0.2), value: showCustomFoodAlert)
                }
                
                if showCustomMealAlert {
                    CustomMealAlert(
                        isPresented: $showCustomMealAlert,
                        quantity: $quantity,
                        mealItem: selectedMeal,
                        onSave: {
                            if let meal = selectedMeal, let quantityValue = Float(quantity.replacingOccurrences(of: ",", with: ".")) {
                                addTrackedFoodViewModel.addTrackedMeal(
                                    meal: meal,
                                    quantity: quantityValue,
                                    daytime: Int16(selectedDaytime),
                                    selectedDate: selectedDate
                                )
                                resetAlert()
                                mainViewModel.updateData()
                            }
                        }, onCancel: {
                            resetAlert()
                        }
                    )
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.2), value: showCustomMealAlert)
                }
                
                if showCustomAlertEditAttributes {
                    buildCustomAlertEditAttributes()
                }
            }
        )
        .searchable(text: $searchText)
        .onChange(of: searchText) {
            addTrackedFoodViewModel.filterFoodItems(by: searchText)
        }
        
        
    }
    
    private func buildCustomAlertEditAttributes() -> some View {
        Group {
            if let food = selectedFood {
                CustomAlertEditFoodAttributes(
                    isPresented: $showCustomAlertEditAttributes,
                    newName: $newName,
                    newUnit: $newUnit,
                    newDefaultQuantity: $newDefaultQuantity,
                    newCalories: $newCalories,
                    newCarbs: $newCarbs,
                    newProtein: $newProtein,
                    newFat: $newFat,
                    foodItem: food,
                    onSave: {
                        print("Funktion aufgerufen")
                        addTrackedFoodViewModel.updateFoodItemAttributes(food: food, newName: newName, newUnit: newUnit, newDefaultQuantity: newDefaultQuantity, newCalories: newCalories, newCarbs: newCarbs, newProtein: newProtein, newFat: newFat)
                        resetAlert()
                        mainViewModel.updateData()
                    },
                    onCancel: {
                        resetAlert()
                    }
                )
            } else {
                EmptyView()
            }
        }
    }
    
    private func resetAlert() {
        withAnimation {
            showCustomFoodAlert = false
            showCustomMealAlert = false
            showCustomAlertEditAttributes = false
        }
        selectedFood = nil
        selectedMeal = nil
        quantity = ""
    }
    
}

// Custom alert view with fields for quantity input and displays food name and default quantity
struct CustomFoodAlert: View {
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

// Custom alert view with fields for quantity input and displays meal name and default quantity
struct CustomMealAlert: View {
    @Binding var isPresented: Bool
    @Binding var quantity: String
    var mealItem: Meal? // Übergebe das gesamte Meal-Objekt
    var onSave: () -> Void
    var onCancel: () -> Void
    
    private var portionAmount: Float {
        guard let defaultQuantity = mealItem?.defaultQuantity else {
            return Float(quantity.replacingOccurrences(of: ",", with: ".")) ?? 1.0
        }
        return Float(quantity.replacingOccurrences(of: ",", with: ".")) ?? Float(defaultQuantity)
    }
    
    var body: some View {
        if isPresented, let meal = mealItem {
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Display the name of the selected meal item
                    Text(meal.name ?? "Unbekannt")
                        .font(.headline)
                        .padding(.top)
                    
                    // Display the default quantity of the meal item
                    Text("Portionsgröße: \(meal.defaultQuantity) \(meal.unit == "Portion" && meal.defaultQuantity > 1 ? "Portionen" : meal.unit ?? "")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Quantity input field
                    TextField("Anzahl an Portionen: \(meal.defaultQuantity)", text: $quantity)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .padding(.horizontal)
                    
                    Divider()
                    
                    VStack {
                        Text("Zutaten:")
                            .font(.subheadline)
                        
                        if let mealFoods = meal.mealFood as? Set<MealFood> {
                            let foodNames = mealFoods.compactMap { $0.food?.name }.sorted()
                            let foodList = foodNames.joined(separator: "\n- ")
                            Text("- \(foodList)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    
                    Divider()
                    
                    Text("Kcal: \(String(format: "%.0f", Float(meal.kcal) / Float(meal.defaultQuantity) * portionAmount))")
                        .font(.subheadline)
                    
                    HStack {
                        Spacer()
                        Text("C: \(String(format: "%.1f", meal.carbohydrate / Float(meal.defaultQuantity) * portionAmount)) g")
                        Spacer()
                        Text("P: \(String(format: "%.1f", meal.protein / Float(meal.defaultQuantity) * portionAmount)) g")
                        Spacer()
                        Text("F: \(String(format: "%.1f", meal.fat / Float(meal.defaultQuantity) * portionAmount)) g")
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

//Custom Alert to edit entry
struct CustomAlertEditFoodAttributes: View {
    @Binding var isPresented: Bool
    @Binding var newName: String
    @Binding var newUnit: String
    @Binding var newDefaultQuantity: String
    @Binding var newCalories: String
    @Binding var newCarbs: String
    @Binding var newProtein: String
    @Binding var newFat: String
    var foodItem: Food? // Übergebe das gesamte Food-Objekt
    var onSave: () -> Void
    var onCancel: () -> Void

    var body: some View {
        if isPresented, let food = foodItem {
            
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {

                    HStack {
                        Text("Name:")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Spacer()
                        TextField("Neuer Name", text: $newName)
                            .font(.headline)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.trailing)
                            .submitLabel(.done)
                            .padding(.trailing, 16.0)
                            .onAppear {
                                newName = food.name ?? ""
                            }
                    }
                    //Divider()
                    HStack {
                        Text("Portionsgröße:")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Spacer()
                        TextField("100", text: $newDefaultQuantity)
                            .keyboardType(.numberPad)
                            .font(.headline)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.trailing)
                            .onAppear {
                                newDefaultQuantity = String(food.defaultQuantity)
                            }
                            .submitLabel(.done)
                            .padding(.trailing, 16.0)
                        
                        
                    }
                    HStack {
                        Text("Einheit:")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Spacer()
                        Picker("Einheit", selection: $newUnit) {
                            Text("Gramm").tag("g")
                            Text("Kilogramm").tag("kg")
                            Text("Milliliter").tag("ml")
                            Text("Liter").tag("l")
                            Text("Stück").tag("Stück")
                        }
                        .pickerStyle(MenuPickerStyle())
                        .onAppear {
                            newUnit = food.unit ?? "g"
                        }
                    }
                    //Divider()
                    HStack {
                        Text("Kalorien (kcal):")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Spacer()
                        TextField("83", text: $newCalories)
                            .keyboardType(.decimalPad)
                            .font(.headline)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.trailing)
                            .submitLabel(.done)
                            .padding(.trailing, 16.0)
                            .onAppear {
                                newCalories = String(food.kcal)
                            }
                    }
                    HStack {
                        Text("Kohlenhydrate:")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Spacer()
                        TextField("43", text: $newCarbs)
                            .keyboardType(.decimalPad)
                            .font(.headline)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.trailing)
                            .submitLabel(.done)
                            .padding(.trailing, 16.0)
                            .onAppear {
                                newCarbs = String(food.carbohydrate)
                            }
                    }
                    HStack {
                        Text("Protein:")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Spacer()
                        TextField("5.1", text: $newProtein)
                            .keyboardType(.decimalPad)
                            .font(.headline)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.trailing)
                            .submitLabel(.done)
                            .padding(.trailing, 16.0)
                            .onAppear {
                                newProtein = String(food.protein)
                            }
                    }
                    HStack {
                        Text("Fett:")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Spacer()
                        TextField("1.3", text: $newFat)
                            .keyboardType(.decimalPad)
                            .font(.headline)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.trailing)
                            .submitLabel(.done)
                            .padding(.trailing, 16.0)
                            .onAppear {
                                newFat = String(food.fat)
                            }
                    }
                    //Divider()
                    HStack {
                        Button("Abbrechen") {
                            isPresented = false
                            onCancel()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Speichern") {
                            onSave()
                            isPresented = false
                        }
                        .buttonStyle(.borderedProminent)
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
        .environmentObject(CreateMealPanelViewModel(context: context))
}
