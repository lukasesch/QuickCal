//
//  createMealPanelViewModel.swift
//  QuickCal
//
//  Created by Lukas Esch on 20.01.25.
//

import Foundation
import CoreData

class CreateMealPanelViewModel: ObservableObject {
    private let context: NSManagedObjectContext
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    @Published var mealFoods: [MealFoodStruct] = []
    @Published var kcalTotal: Float = 0
    @Published var carbsTotal: Float = 0
    @Published var proteinTotal: Float = 0
    @Published var fatTotal: Float = 0
    
    func deleteIngredient(at offsets: IndexSet) {
        mealFoods.remove(atOffsets: offsets)
        calculateTotals()
    }
    
    func addIngredient (food: Food, quantity: Float) {
        let mealFood = MealFoodStruct(food: food, quantity: quantity)
        mealFoods.append(mealFood)
        calculateTotals()
    }
    
    func calculateTotals() {
        kcalTotal = 0
        carbsTotal = 0
        proteinTotal = 0
        fatTotal = 0
        
        for mealFood in mealFoods {
            kcalTotal += Float(mealFood.food.kcal) * Float(mealFood.quantity)
            carbsTotal += Float(mealFood.food.carbohydrate) * Float(mealFood.quantity)
            proteinTotal += Float(mealFood.food.protein) * Float(mealFood.quantity)
            fatTotal += Float(mealFood.food.fat) * Float(mealFood.quantity)
        }
    }
    
    func clearStruct() {
        mealFoods.removeAll()
        kcalTotal = 0
        carbsTotal = 0
        proteinTotal = 0
        fatTotal = 0
    }
    
    func saveMealToDB(name: String, defaultQuantity: String) {
        let newMeal = Meal(context: context)
        newMeal.name = name.isEmpty ? "Unbekanntes Gericht" : name
        if let defaultQuantityValue = Int16(defaultQuantity.isEmpty ? "1" : defaultQuantity) {
            newMeal.defaultQuantity = defaultQuantityValue
        } else {
            print("Ungültiger Wert für defaultQuantity: \(defaultQuantity)")
            return
        }
        newMeal.lastUsed = Date()
        newMeal.kcal = Int16(kcalTotal.rounded())
        newMeal.carbohydrate = carbsTotal
        newMeal.protein = proteinTotal
        newMeal.fat = fatTotal
        newMeal.unit = "Portion"
        
        
        for mealFood in mealFoods {
            let newMealFood = MealFood(context: context)
            newMealFood.food = mealFood.food
            newMealFood.quantity = mealFood.quantity
            newMealFood.meal = newMeal
        }
        
        //Speichern
        do {
            try context.save()
            print("Gericht erfolgreich in DB gespeichert")
            //print("\(newMeal.name), \(newMeal.defaultQuantity), \(newMeal.unit), \(newMeal.kcal), \(newMeal.carbohydrate), \(newMeal.protein), \(newMeal.fat)")
        } catch {
            print("Gericht konnte nicht gespeichert werden: \(error.localizedDescription)")
        }
    }
    
    struct MealFoodStruct: Identifiable {
        let id: UUID = UUID()
        let food: Food
        var quantity: Float
    }
}
