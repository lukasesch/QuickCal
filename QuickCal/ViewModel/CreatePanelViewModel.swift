//
//  CreatePanelViewModel.swift
//  QuickCal
//
//  Created by Lukas Esch on 03.11.24.
//

import Foundation
import CoreData

final class CreatePanelViewModel: ObservableObject {
    private let context: NSManagedObjectContext
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    //@Published var food: Food?

    func createFood(name: String, defaultQuantity: String, unit: String, calories: String, carbs: String, protein: String, fat: String) {
        
        let food = Food(context: context)
        
        food.name = name
        
        if let defaultQuantityFloat = Float(defaultQuantity.replacingOccurrences(of: ",", with: ".")) {
            food.defaultQuantity = defaultQuantityFloat
        }
        food.unit = unit
        if let caloriesInt = Int16(calories.replacingOccurrences(of: ",", with: ".")) {
            food.kcal = caloriesInt
        }
        if let carbsFloat = Float(carbs.replacingOccurrences(of: ",", with: ".")) {
            food.carbohydrate = carbsFloat
        }
        if let proteinFloat = Float(protein.replacingOccurrences(of: ",", with: ".")) {
            food.protein = proteinFloat
        }
        if let fatFloat = Float(fat.replacingOccurrences(of: ",", with: ".")) {
            food.fat = fatFloat
        }
        
        //Speichern
        do {
            try context.save()
            print("Lebensmittel erfolgreich in DB gespeichert")
        } catch {
            print("Benutzer konnte nicht gespeichert werden: \(error.localizedDescription)")
        }
    }
}
