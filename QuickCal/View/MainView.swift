//
//  MainView.swift
//  QuickCal
//
//  Created by Lukas Esch on 09.10.24.
//

import SwiftUI
import CoreData

struct MainView: View {
    
    @EnvironmentObject var mainViewModel: MainViewModel
    //@Environment(\.managedObjectContext) private var viewContext
    @AppStorage("onboarding") private var onboardingDone = false
    //@State private var currentPage = 1
    @State private var showingSettings = false
    //@State private var showAddTrackedFoodPanel = false
    @State private var selectedDaytime: Int? = nil
    
    //Custom Alert to edit entries
    @State private var showCustomAlert = false
    @State private var selectedFood: TrackedFood?
    @State private var quantity: String = ""


    var body: some View {
        NavigationStack {
            
                VStack {
                    HStack {
                        Text("QuickCal")
                            .font(.title)
                            .fontWeight(.heavy)
                            .multilineTextAlignment(.leading)
                            .padding(.top, 5.0)
                            .padding(.bottom, -2.0)
                        Spacer()
                        
                        Button(action: {
                            showingSettings.toggle()
                        }) {
                            Image(systemName: "gearshape")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        .sheet(isPresented: $showingSettings) {
                            SettingsView()
                        }
                    }
                    .padding(.horizontal, 25.0)
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    Spacer()
                    Spacer()
                    //Spacer()
                    
                    HStack {
                        Spacer()
                        HalfCircularProgressView(barColor: .blue, barWidth: 18, progressPercentage: mainViewModel.kcalProgressPercentage)
                            .frame(width: 180, height: 200)
                            
                        Spacer()
                    }
                    .padding(.bottom, -40)
                    HStack {
                        Spacer()
                        Spacer()
                        MacroBars(barColor: .green, barWidth: 90, barHeight: 12, goal: mainViewModel.carbsGoal, progressPercentage: mainViewModel.carbsProgressPercentage, barName: "Kohlenhydrate")
                        Spacer()
                        MacroBars(barColor: .orange, barWidth: 90, barHeight: 12, goal: mainViewModel.proteinGoal, progressPercentage: mainViewModel.proteinProgressPercentage, barName: "Protein")
                        Spacer()
                        MacroBars(barColor: .purple, barWidth: 90, barHeight: 12, goal: mainViewModel.fatGoal, progressPercentage: mainViewModel.fatProgressPercentage, barName: "Fett")
                        Spacer()
                        Spacer()
                    }
                    
                    Spacer()
    
                    List {
                        Section {
                            ForEach(mainViewModel.trackedFood(forDaytime: 0)) { food in
                                let portion = food.quantity
                                let kcal = food.food?.kcal ?? 0
                                let totalkcal = Float(kcal) * portion
                                HStack {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text("\(food.food?.name ?? "Unknown Food"), \(String(format: "%.0f", food.food?.defaultQuantity ?? 0)) \(food.food?.unit ?? "")")
                                        }
                                        Text(food.quantity.truncatingRemainder(dividingBy: 1) == 0 ?
                                             "\(Int(food.quantity))" :
                                                "\(String(format: "%.1f", food.quantity))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(String(format: "%.0f", totalkcal)) kcal") // Kalorien
    
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedFood = food
                                    quantity = food.quantity.truncatingRemainder(dividingBy: 1) == 0
                                    ? String(Int(food.quantity)) // Whole Number
                                    : String(format: "%.1f", food.quantity) // Decimal Number
                                    withAnimation {
                                        showCustomAlert = true
                                    }
                                }
                            }
                            .onDelete { offsets in
                                mainViewModel.deleteTrackedFoodItem(at: offsets, forDaytime: 0)
                            }
                        } header: {
                            VStack {
                                HStack {
                                    Text("Frühstück")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Button(action: {
                                        //print("Button pressed")
                                        selectedDaytime = 0
                                        mainViewModel.showAddTrackedFoodPanel.toggle()
                                    }) {
                                        Image(systemName: "plus")
                                            .fontWeight(.semibold)
                                    }
                                    
                                    
                                }
                                Divider()
                                HStack {
                                    Text("Kcal: \(String(format: "%.0f", mainViewModel.kcalMorning))")
                                    Spacer()
                                    Text("C: \(String(format: "%.0f", mainViewModel.carbsMorning)) g")
                                    Spacer()
                                    Text("P: \(String(format: "%.0f", mainViewModel.proteinMorning)) g")
                                    Spacer()
                                    Text("F: \(String(format: "%.0f", mainViewModel.fatMorning)) g")
                                    Spacer()
                                }
                                .font(.footnote)
                            }
                        }
                        Section {
                            ForEach(mainViewModel.trackedFood(forDaytime: 1)) { food in
                                let portion = food.quantity
                                let kcal = food.food?.kcal ?? 0
                                let totalkcal = Float(kcal) * portion
                                HStack {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text("\(food.food?.name ?? "Unknown Food"), \(String(format: "%.0f", food.food?.defaultQuantity ?? 0)) \(food.food?.unit ?? "")")
                                        }
                                        Text(food.quantity.truncatingRemainder(dividingBy: 1) == 0 ?
                                             "\(Int(food.quantity))" :
                                                "\(String(format: "%.1f", food.quantity))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(String(format: "%.0f", totalkcal)) kcal") // Kalorien
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedFood = food
                                    quantity = food.quantity.truncatingRemainder(dividingBy: 1) == 0
                                    ? String(Int(food.quantity)) // Whole Number
                                    : String(format: "%.1f", food.quantity) // Decimal Number
                                    withAnimation {
                                        showCustomAlert = true
                                    }
                                }
                            }
                            .onDelete { offsets in
                                mainViewModel.deleteTrackedFoodItem(at: offsets, forDaytime: 1)
                            }
                        } header: {
                            VStack {
                                HStack {
                                    Text("Mittagessen")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Button(action: {
                                        //print("Button pressed")
                                        selectedDaytime = 1
                                        mainViewModel.showAddTrackedFoodPanel.toggle()
                                    }) {
                                        Image(systemName: "plus")
                                            .fontWeight(.semibold)
                                    }
                                    
                                }
                                Divider()
                                HStack {
                                    Text("Kcal: \(String(format: "%.0f", mainViewModel.kcalMidday))")
                                    Spacer()
                                    Text("C: \(String(format: "%.0f", mainViewModel.carbsMidday)) g")
                                    Spacer()
                                    Text("P: \(String(format: "%.0f", mainViewModel.proteinMidday)) g")
                                    Spacer()
                                    Text("F: \(String(format: "%.0f", mainViewModel.fatMidday)) g")
                                    Spacer()
                                }
                                .font(.footnote)
                            }
                        }
                        Section {
                            ForEach(mainViewModel.trackedFood(forDaytime: 2)) { food in
                                let portion = food.quantity
                                let kcal = food.food?.kcal ?? 0
                                let totalkcal = Float(kcal) * portion
                                HStack {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text("\(food.food?.name ?? "Unknown Food"), \(String(format: "%.0f", food.food?.defaultQuantity ?? 0)) \(food.food?.unit ?? "")")
                                        }
                                        Text(food.quantity.truncatingRemainder(dividingBy: 1) == 0 ?
                                             "\(Int(food.quantity))" :
                                                "\(String(format: "%.1f", food.quantity))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(String(format: "%.0f", totalkcal)) kcal") // Kalorien
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedFood = food
                                    quantity = food.quantity.truncatingRemainder(dividingBy: 1) == 0
                                    ? String(Int(food.quantity)) // Whole Number
                                    : String(format: "%.1f", food.quantity) // Decimal Number
                                    withAnimation {
                                        showCustomAlert = true
                                    }
                                }
                            }
                            .onDelete { offsets in
                                mainViewModel.deleteTrackedFoodItem(at: offsets, forDaytime: 2)
                            }
                        } header: {
                            VStack {
                                HStack {
                                    Text("Abendessen")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Button(action: {
                                        //print("Button pressed")
                                        selectedDaytime = 2
                                        mainViewModel.showAddTrackedFoodPanel.toggle()
                                    }) {
                                        Image(systemName: "plus")
                                            .fontWeight(.semibold)
                                    }
                                                                    }
                                Divider()
                                HStack {
                                    Text("Kcal: \(String(format: "%.0f", mainViewModel.kcalEvening))")
                                    Spacer()
                                    Text("C: \(String(format: "%.0f", mainViewModel.carbsEvening)) g")
                                    Spacer()
                                    Text("P: \(String(format: "%.0f", mainViewModel.proteinEvening)) g")
                                    Spacer()
                                    Text("F: \(String(format: "%.0f", mainViewModel.fatEvening)) g")
                                    Spacer()
                                }
                                .font(.footnote)
                            }
                        }
                        Section {
                            ForEach(mainViewModel.trackedFood(forDaytime: 3)) { food in
                                let portion = food.quantity
                                let kcal = food.food?.kcal ?? 0
                                let totalkcal = Float(kcal) * portion
                                HStack {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text("\(food.food?.name ?? "Unknown Food"), \(String(format: "%.0f", food.food?.defaultQuantity ?? 0)) \(food.food?.unit ?? "")") // Name des Lebensmittels
                                        }
                                        Text(food.quantity.truncatingRemainder(dividingBy: 1) == 0 ?
                                             "\(Int(food.quantity))" :
                                                "\(String(format: "%.1f", food.quantity))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(String(format: "%.0f", totalkcal)) kcal") // Kalorien
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedFood = food
                                    quantity = food.quantity.truncatingRemainder(dividingBy: 1) == 0
                                    ? String(Int(food.quantity)) // Whole Number
                                    : String(format: "%.1f", food.quantity) // Decimal Number
                                    withAnimation {
                                        showCustomAlert = true
                                    }
                                    
                                }
                            }
                            .onDelete { offsets in
                                mainViewModel.deleteTrackedFoodItem(at: offsets, forDaytime: 3)
                            }
                        } header: {
                            VStack {
                                HStack {
                                    Text("Snacks")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Button(action: {
                                        //print("Button pressed")
                                        selectedDaytime = 3
                                        mainViewModel.showAddTrackedFoodPanel.toggle()
                                    }) {
                                        Image(systemName: "plus")
                                            .fontWeight(.semibold)
                                    }
                                    
                                }
                                Divider()
                                HStack {
                                    Text("Kcal: \(String(format: "%.0f", mainViewModel.kcalSnacks))")
                                    Spacer()
                                    Text("C: \(String(format: "%.0f", mainViewModel.carbsSnacks)) g")
                                    Spacer()
                                    Text("P: \(String(format: "%.0f", mainViewModel.proteinSnacks)) g")
                                    Spacer()
                                    Text("F: \(String(format: "%.0f", mainViewModel.fatSnacks)) g")
                                    Spacer()
                                }
                                .font(.footnote)
                            }
                        }
                        
                    }
                    .sheet(isPresented: $mainViewModel.showAddTrackedFoodPanel) {
                        if let daytime = selectedDaytime {
                            AddTrackedFoodView(showAddTrackedFoodPanel: $mainViewModel.showAddTrackedFoodPanel, selectedDaytime: daytime)
                        }
                    }
                    .listStyle(.grouped)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding()
                    .shadow(radius: 5)
                    
                    
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    
                    
                    
                }
                .navigationBarBackButtonHidden(true)
                .onAppear {
                    //Preview debugging as no user exists here
                    if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                        mainViewModel.kcalGoal = 2000
                        mainViewModel.kcalReached = 0
                        mainViewModel.carbsGoal = 200
                        mainViewModel.proteinGoal = 100
                        mainViewModel.fatGoal = 70
                    } else {
                        mainViewModel.checkAndCalculateDailyCalories()
                        print("MainView: checkAndCalculateDailyCalories run!")
                    }
                    //mainViewModel.fetchTrackedFood()
                    mainViewModel.updateData()
                }
          
            .tabViewStyle(.page)
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            .padding(.bottom, 10)
            .ignoresSafeArea(.container, edges: .bottom)
            
        }
        .overlay(
            Group {
                if showCustomAlert {
                    CustomAlertEdit(
                        isPresented: $showCustomAlert,
                        quantity: $quantity,
                        foodItem: selectedFood?.food,
                        onSave: {
                            if let food = selectedFood, let quantityValue = Float(quantity.replacingOccurrences(of: ",", with: ".")) {
                                mainViewModel.updateTrackedFoodQuantity(food: food, newQuantity: quantityValue)
                                resetAlert()
                            }
                            mainViewModel.updateData()
                        },
                        onCancel: {
                            resetAlert()
                        }
                    )
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: showCustomAlert)
        )
        
    }
    
    private func resetAlert() {
        withAnimation {
            showCustomAlert = false
        }
        selectedFood = nil
        quantity = ""
    }
    

    struct HalfCircularProgressView: View {
        @EnvironmentObject var mainViewModel: MainViewModel
        var barColor: Color
        var barWidth: CGFloat
        var progressPercentage: CGFloat
        var body: some View {
            ZStack {
                Circle()
                    .trim(from: 0, to: 0.63)
                    .stroke(
                        barColor.opacity(0.25),
                        style: StrokeStyle(lineWidth: barWidth, lineCap: .round))
                    .rotationEffect(Angle(degrees: 157))
                Circle()
                    .trim(from: 0, to: 0.63 * min(progressPercentage, 1.0))
                    .stroke(
                        barColor,
                        style: StrokeStyle(lineWidth: barWidth, lineCap: .round))
                    .rotationEffect(Angle(degrees: 157))
                // Calories overrreached, red transition
                if progressPercentage > 1.0 {
                    Circle()
                        .trim(from: 0, to: 0.63)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [barColor, .red]),
                                center: .center,
                                startAngle: .degrees(0), // Dynamischer Startwinkel
                                endAngle: .degrees(227)
                            ),
                            style: StrokeStyle(lineWidth: barWidth, lineCap: .round)
                        )
                        .rotationEffect(Angle(degrees: 157))
                }
                
                VStack {
                    Text("""
                        \(String(format: "%.0f", mainViewModel.kcalReached))
                        """)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    
                    Text("""
                        von
                         \(String(format: "%.0f", mainViewModel.kcalGoal)) kcal
                        """)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
                } 
            }
        }
    }
    
    struct MacroBars: View {
        var barColor: Color
        var barWidth: CGFloat
        var barHeight: CGFloat
        var goal: Int
        var progressPercentage: Double
        var barName: String
        var body: some View {
            VStack {
                Text("\(barName)")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                ZStack (alignment: .leading) {
                    Rectangle()
                        .frame(width: barWidth, height: barHeight)
                        .foregroundStyle(barColor)
                        .opacity(0.25)
                        .clipShape(.capsule)
                    Rectangle()
                        .frame(width: barWidth * min(progressPercentage, 1.0), height: barHeight)
                        .foregroundStyle(barColor)
                        .clipShape(.capsule)
                }
                Text("\(String(format: "%.0f", (Double(goal) * progressPercentage))) / \(goal) g")
                    .font(.footnote)
                    .fontWeight(.regular)
                    .multilineTextAlignment(.center)
                
            }
        }
    }
}

// Custom alert view with fields for quantity input and displays food name and default quantity
struct CustomAlertEdit: View {
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
                    TextField("", text: $quantity)
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
                        
                        Button("Ändern") {
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
    MainView()
        .environment(\.managedObjectContext, context)
        .environmentObject(MainViewModel(context: context))
        .environmentObject(SettingsViewModel(context: context))
        .environmentObject(AddTrackedFoodViewModel(context: context))
}
