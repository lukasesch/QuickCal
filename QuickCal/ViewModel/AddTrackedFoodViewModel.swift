//
//  AddTrackedFoodViewModel.swift
//  QuickCal
//
//  Created by Lukas Esch on 05.11.24.
//

import SwiftUI
import CoreData
import CryptoKit

class AddTrackedFoodViewModel: ObservableObject {
    
    private let context: NSManagedObjectContext
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchFoodItems()
        fetchMealItems()
    }
    
    @Published var foodItems: [Food] = []
    @Published var mealItems: [Meal] = []
    private var allFoodItems: [Food] = []
    private var allMealItems: [Meal] = []
    
    func fetchFoodItems() {
        let request: NSFetchRequest<Food> = Food.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Food.lastUsed, ascending: false)]
        
        do {
            allFoodItems = try context.fetch(request)
            foodItems = allFoodItems
        } catch {
            print("Failed to fetch food items: \(error)")
        }
    }
    
    func fetchMealItems() {
        let request: NSFetchRequest<Meal> = Meal.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Meal.lastUsed, ascending: false)]
        
        do {
            allMealItems = try context.fetch(request)
            mealItems = allMealItems
        } catch {
            print("Failed to fetch meal items: \(error)")
        }
    }
    
    func filterFoodItems(by searchText: String) {
        if searchText.isEmpty {
            foodItems = allFoodItems // Reset to all items if the search is empty
        } else {
            foodItems = allFoodItems.filter { food in
                (food.name?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }
    
    func addTrackedFood(food: Food, quantity: Float, daytime: Int16, selectedDate: Date) {
        let trackedFood = TrackedFood(context: context)
        trackedFood.date = selectedDate
        trackedFood.daytime = daytime
        trackedFood.quantity = quantity
        trackedFood.food = food
        food.lastUsed = Date()
        
        do {
            try context.save()
            print("Tracked \(food.name ?? "Unbekannt") saved successfully!")
        } catch {
            print("Failed to save tracked food: \(error)")
        }
        fetchFoodItems()
    }
    
    func addTrackedMeal(meal: Meal, quantity: Float, daytime: Int16, selectedDate: Date) {
        guard let mealFoods = meal.mealFood as? Set<MealFood> else {
            print("No meal foods found for this meal.")
            return
        }
        
        for mealFood in mealFoods {
            guard let food = mealFood.food else {
                print("MealFood does not have an associated Food entity.")
                continue
            }
            
            let adjustedQuantity = (mealFood.quantity) * quantity / Float(meal.defaultQuantity)
            addTrackedFood(food: food, quantity: adjustedQuantity, daytime: daytime, selectedDate: selectedDate)
        }
        
        meal.lastUsed = Date()
        
        // Speichere die Änderungen
        do {
            try context.save()
            print("Meal lastUsed updated successfully!")
        } catch {
            print("Failed to update meal lastUsed: \(error)")
        }
        fetchMealItems()
    }
    
    func deleteFoodItem(at offsets: IndexSet) {
        offsets.forEach { index in
            let food = foodItems[index]
            context.delete(food)
        }
        
        do {
            try context.save()
            foodItems.remove(atOffsets: offsets)
        } catch {
            print("Failed to delete food item: \(error)")
        }
    }
    
    func deleteMealItem(at offsets: IndexSet) {
        offsets.forEach { index in
            let meal = mealItems[index]
            context.delete(meal)
        }
        
        do {
            try context.save()
            mealItems.remove(atOffsets: offsets)
        } catch {
            print("Failed to delete food item: \(error)")
        }
    }
    
    func updateFoodItemAttributes(food: Food, newName: String, newUnit: String, newDefaultQuantity: String, newCalories: String, newCarbs: String, newProtein: String, newFat: String) {
        food.name = newName
        food.unit = newUnit
        
        // Konvertieren der Strings zu CoreDate Datentypen
        if let defaultQuantity = Float(newDefaultQuantity.replacingOccurrences(of: ",", with: ".")) {
            food.defaultQuantity = defaultQuantity
        }
        if let calories = Int16(newCalories.replacingOccurrences(of: ",", with: ".")) {
            food.kcal = calories
        }
        if let carbs = Float(newCarbs.replacingOccurrences(of: ",", with: ".")) {
            food.carbohydrate = carbs
        }
        if let protein = Float(newProtein.replacingOccurrences(of: ",", with: ".")) {
            food.protein = protein
        }
        if let fat = Float(newFat.replacingOccurrences(of: ",", with: ".")) {
            food.fat = fat
        }
        
        // Generate new UniqueID
        let hashString = "\(newName)\(newDefaultQuantity)\(newUnit)\(newCalories)\(newCarbs)\(newProtein)\(newFat)"
        let hash = SHA256.hash(data: Data(hashString.utf8))
        let uniqueID = hash.compactMap { String(format: "%02x", $0) }.joined()
        food.uniqueID = uniqueID
        

        do {
            try context.save()
            print("Food-Item '\(food.name ?? "Unknown")' erfolgreich aktualisiert!")
        } catch {
            print("Fehler beim Aktualisieren des Food-Items: \(error.localizedDescription)")
        }
        
        fetchFoodItems()
    }
}
