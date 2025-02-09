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
    @AppStorage("onboarding") private var onboardingDone = false
    @State private var showingSettings = false
    @State private var selectedDaytime: Int? = nil
    
    //Easter Egg
    @State private var tapCount = 0
    @State private var isWobbling = false
    @State private var resetTimer: Timer?
    
    //Custom Alert to edit entries
    @State private var showCustomAlert = false
    @State private var showCustomAlertEditAttributes = false
    @State private var selectedFood: TrackedFood?
    @State private var quantity: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack(alignment: .center) {
                    Image("Icon")
                        .resizable()
                        .frame(width: 42, height: 42)
                        .rotationEffect(.degrees(isWobbling ? -15 : 0))
                        .scaleEffect(isWobbling ? 1.2 : 1)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isWobbling)
                        .onTapGesture(perform: handleIconTap)
                    
                    Spacer()
                    Text(
                        Calendar.current.isDate(mainViewModel.selectedDate, inSameDayAs: Date())
                        ? "Heute"
                        : Calendar.current.isDate(mainViewModel.selectedDate, inSameDayAs: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
                        ? "Gestern"
                        : Calendar.current.isDate(mainViewModel.selectedDate, inSameDayAs: Calendar.current.date(byAdding: .day, value: -2, to: Date())!)
                        ? "Vorgestern"
                        : formattedDate(mainViewModel.selectedDate)
                    )
                    .font(.headline)
                    .foregroundColor(.blue)
                    .onTapGesture {
                        mainViewModel.showingDatePicker.toggle()
                    }
                    Image(systemName: "chevron.down")
                        .foregroundColor(.blue)
                        .onTapGesture {
                            mainViewModel.showingDatePicker.toggle()
                        }
                        .sheet(isPresented: $mainViewModel.showingDatePicker) {
                            VStack {
                                DatePicker(
                                    "Datum auswählen:",
                                    selection: $mainViewModel.selectedDate,
                                    displayedComponents: [.date]
                                )
                                .datePickerStyle(.graphical)
                                .labelsHidden()
                                .onChange(of: mainViewModel.selectedDate) {
                                    mainViewModel.showingDatePicker = false
                                    mainViewModel.updateData()
                                }
                                
                                
                            }
                            .presentationDetents([.fraction(0.51)])
                            .presentationDragIndicator(.hidden)
                            Spacer()
                        }
                    
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
                    .frame(width: 42, height: 42)
                }
                .padding(.horizontal, 15.0)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                Spacer()
                

                HStack {
                    Spacer()
                    HalfCircularProgressView(barColor: .blue, barWidth: 14, progressPercentage: mainViewModel.kcalProgressPercentage)
                        .frame(width: 180, height: 200)
                    
                    Spacer()
                }
                .padding(.bottom, -40)
                HStack {
                    Spacer()
                    Spacer()
                    MacroBars(barColor: .green, barWidth: 90, barHeight: 9, goal: mainViewModel.carbsGoal, progressPercentage: mainViewModel.carbsProgressPercentage, barName: "Kohlenhydrate")
                    Spacer()
                    MacroBars(barColor: .orange, barWidth: 90, barHeight: 9, goal: mainViewModel.proteinGoal, progressPercentage: mainViewModel.proteinProgressPercentage, barName: "Protein")
                    Spacer()
                    MacroBars(barColor: .purple, barWidth: 90, barHeight: 9, goal: mainViewModel.fatGoal, progressPercentage: mainViewModel.fatProgressPercentage, barName: "Fett")
                    Spacer()
                    Spacer()
                }
                
                Spacer()
                
                List {
                    Section {
                        ForEach(mainViewModel.trackedFood(forDaytime: 0)) { food in
                            let portion = food.quantity
                            let kcal = food.food?.kcal ?? 0
                            let defaultQuantity = food.food?.defaultQuantity ?? 0
                            let totalkcal = Float(kcal) * portion
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("\(food.food?.name ?? "Unknown Food")")
                                            Text("\(String(format: "%.0f", (food.quantity * defaultQuantity))) \(food.food?.unit ?? "")")
                                                .font(.footnote)
                                        }
                                        Spacer()
                                        Text("\(String(format: "%.0f", totalkcal)) kcal") // Kalorien
                                    }
                                }
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
                                Text("K: \(String(format: "%.0f", mainViewModel.carbsMorning)) g")
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
                            let defaultQuantity = food.food?.defaultQuantity ?? 0
                            let totalkcal = Float(kcal) * portion
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("\(food.food?.name ?? "Unknown Food")")
                                            Text("\(String(format: "%.0f", (food.quantity * defaultQuantity))) \(food.food?.unit ?? "")")
                                                .font(.footnote)
                                        }
                                        Spacer()
                                        Text("\(String(format: "%.0f", totalkcal)) kcal") // Kalorien
                                    }
                                }
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
                                Text("K: \(String(format: "%.0f", mainViewModel.carbsMidday)) g")
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
                            let defaultQuantity = food.food?.defaultQuantity ?? 0
                            let totalkcal = Float(kcal) * portion
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("\(food.food?.name ?? "Unknown Food")")
                                            Text("\(String(format: "%.0f", (food.quantity * defaultQuantity))) \(food.food?.unit ?? "")")
                                                .font(.footnote)
                                        }
                                        Spacer()
                                        Text("\(String(format: "%.0f", totalkcal)) kcal") // Kalorien
                                    }
                                }
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
                                Text("K: \(String(format: "%.0f", mainViewModel.carbsEvening)) g")
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
                            let defaultQuantity = food.food?.defaultQuantity ?? 0
                            let totalkcal = Float(kcal) * portion
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("\(food.food?.name ?? "Unknown Food")")
                                            Text("\(String(format: "%.0f", (food.quantity * defaultQuantity))) \(food.food?.unit ?? "")")
                                                .font(.footnote)
                                        }
                                        Spacer()
                                        Text("\(String(format: "%.0f", totalkcal)) kcal") // Kalorien
                                    }
                                }
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
                                Text("K: \(String(format: "%.0f", mainViewModel.carbsSnacks)) g")
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
                        AddTrackedFoodView(showAddTrackedFoodPanel: $mainViewModel.showAddTrackedFoodPanel, selectedDaytime: daytime, selectedDate: mainViewModel.selectedDate)
                        
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
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white,
                        Color.gray.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .background(Color(UIColor.systemGroupedBackground))
                .ignoresSafeArea()
            )
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
                    .animation(.easeInOut(duration: 0.2), value: showCustomAlert)
                }
            }
        )
        
    }
    private func handleIconTap() {
        tapCount += 1
        resetTimer?.invalidate()
        
        if tapCount == 3 {
            triggerWobble()
            tapCount = 0
        } else {
            resetTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                tapCount = 0
            }
        }
    }
    
    private func triggerWobble() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.4, blendDuration: 0.2)) {
            isWobbling = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                isWobbling = false
            }
        }
    }
    
    private func resetAlert() {
        withAnimation {
            showCustomAlert = false
        }
        selectedFood = nil
        quantity = ""
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "d. MMMM" // Jahr weglassen
        return formatter.string(from: date)
    }
    
    struct HalfCircularProgressView: View {
        @EnvironmentObject var mainViewModel: MainViewModel
        let darkBlue = Color(red: 15/255, green: 32/255, blue: 85/255)
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
                //                    .shadow(radius: 5)
                Circle()
                    .trim(from: 0, to: 0.63 * min(progressPercentage, 1.0))
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [barColor, darkBlue]),
                            center: .center,
                            startAngle: .degrees(0), // Dynamischer Startwinkel
                            endAngle: .degrees(227)
                        ),
                        style: StrokeStyle(lineWidth: barWidth, lineCap: .round)
                    )
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
                
                VStack(spacing: 4) {
                    Text("\(String(format: "%.0f", mainViewModel.kcalReached))")
                        .font(.system(size: 42, weight: .heavy, design: .rounded))
                        .padding(.top, -15.0)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [darkBlue, modifiedColor(base: barColor)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    Text("/ \(String(format: "%.0f", mainViewModel.kcalGoal)) kcal")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.primary.opacity(0.8)) // Höherer Kontrast
                        .shadow(color: .white.opacity(0.3), radius: 2, x: 0, y: 1) // Textumriss
                }
            }
        }
        
        // Farbanpassung (unverändert)
        private func modifiedColor(base: Color) -> Color {
            let uiColor = UIColor(base)
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            
            uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            
            return Color(
                hue: Double(hue),
                saturation: Double(min(saturation * 1.3, 1.0)),
                brightness: Double(min(brightness * 1.2, 1.0)),
                opacity: Double(alpha)
            )
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
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    barColor,
                                    barColor.darker(by: 0.2)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
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
                    Text("Portionsgröße: \(String(format: "%.1f", food.defaultQuantity)) \(food.unit ?? "")")
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
                        Text("K: \(String(format: "%.1f", food.carbohydrate * portionAmount)) g")
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
        .environmentObject(CreateMealPanelViewModel(context: context))
        .environmentObject(BarCodeViewModel(context: context))
}

extension Color {
    func darker(by percentage: CGFloat) -> Color {
        let uiColor = UIColor(self)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getHue(
            &hue,
            saturation: &saturation,
            brightness: &brightness,
            alpha: &alpha
        )
        
        return Color(
            hue: Double(hue),
            saturation: Double(saturation),
            brightness: Double(max(brightness - percentage, 0)),
            opacity: Double(alpha)
        )
    }
    
    func lighter(by percentage: CGFloat) -> Color {
        let uiColor = UIColor(self)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getHue(
            &hue,
            saturation: &saturation,
            brightness: &brightness,
            alpha: &alpha
        )
        
        return Color(
            hue: Double(hue),
            saturation: Double(saturation),
            brightness: Double(max(brightness + percentage, 0)),
            opacity: Double(alpha)
        )
    }
}
