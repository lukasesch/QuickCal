//
//  CreatePanelViewModel.swift
//  QuickCal
//
//  Created by Lukas Esch on 03.11.24.
//

import Foundation
import CoreData
import CryptoKit

final class CreateFoodPanelViewModel: ObservableObject {
    private let context: NSManagedObjectContext
    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func createFood(name: String, defaultQuantity: String, unit: String, calories: String, carbs: String, protein: String, fat: String) {
        // Unique Hash in Hexadezimal erstellen
        let hashString = "\(name)\(defaultQuantity)\(unit)\(calories)\(carbs)\(protein)\(fat)"
        let hash = SHA256.hash(data: Data(hashString.utf8))
        let uniqueID = hash.compactMap { String(format: "%02x", $0) }.joined()
        
        // Existiert es bereits?
        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uniqueID == %@", uniqueID)
        
        var food: Food?
        do {
            let existingFoods = try context.fetch(fetchRequest)
            if let existingFood = existingFoods.first {
                // Existiert bereits
                print("Lebensmittel existiert bereits in der Datenbank: \(name)")
                food = existingFood
                food?.lastUsed = Date()
            } else {
                // Existiert noch nicht
                food = Food(context: context)
                food?.name = name
                if let defaultQuantityFloat = Float(defaultQuantity.replacingOccurrences(of: ",", with: ".")) {
                    food?.defaultQuantity = defaultQuantityFloat
                }
                
                food?.unit = unit
                if let caloriesInt = Int16(calories.replacingOccurrences(of: ",", with: ".")) {
                    food?.kcal = caloriesInt
                }
                
                if let carbsFloat = Float(carbs.replacingOccurrences(of: ",", with: ".")) {
                    food?.carbohydrate = carbsFloat
                }
                
                if let proteinFloat = Float(protein.replacingOccurrences(of: ",", with: ".")) {
                    food?.protein = proteinFloat
                }
                
                if let fatFloat = Float(fat.replacingOccurrences(of: ",", with: ".")) {
                    food?.fat = fatFloat
                }
                
                food?.uniqueID = uniqueID
                food?.lastUsed = Date()
                print("Neues Lebensmittel wurde erstellt: \(name)")
            }
        } catch {
            print("Fehler beim Abrufen von Lebensmitteln: \(error.localizedDescription)")
            return
        }
        
        // Speichern in DB
        do {
            try context.save()
            print("Lebensmittel erfolgreich aktualisiert (lastUsed) und in TrackedFood gespeichert")
        } catch {
            print("Fehler beim Speichern: \(error.localizedDescription)")
        }
        
    }
}
