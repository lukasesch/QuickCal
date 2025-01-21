//
//  createMealPanelViewModel.swift
//  QuickCal
//
//  Created by Lukas Esch on 20.01.25.
//

import Foundation

class CreateMealPanelViewModel: ObservableObject {
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
    
    struct MealFoodStruct: Identifiable {
        let id: UUID = UUID()
        let food: Food
        var quantity: Float
    }
}
