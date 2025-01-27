//
//  OpenFoodFactsViewModel.swift
//  QuickCal
//
//  Created by Lukas Esch on 17.11.24.
//

import Foundation
import SwiftUI
import CoreData
import CryptoKit

class OpenFoodFactsViewModel: ObservableObject {
    @EnvironmentObject var mainViewModel: MainViewModel
    @Published var products: [FoodItem] = []
    private let context: NSManagedObjectContext
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func search(text query: String) {
        print("Search initiated for: \(query)")
        
        let baseUrl = "https://de.openfoodfacts.org"
        let urlString = "\(baseUrl)/cgi/search.pl?search_terms=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&action=process&json=true"
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        print("Requesting URL: \(url)")
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.products = [] 
                }
                return
            }
            
            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    self.products = []
                }
                return
            }
            
            do {
                // Parse Data
                guard let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      let productsArray = jsonResponse["products"] as? [[String: Any]] else {
                    print("Invalid JSON structure")
                    DispatchQueue.main.async {
                        self.products = []
                    }
                    return
                }
                
                // Convert to FoodItems
                let foodItems = productsArray.compactMap { product -> FoodItem? in
                    // Specify data from json
                    let brand = product["brands"] as? String ?? "Unbekannte Marke"
                    let name = product["product_name"] as? String ?? "Unbekanntes Produkt"
                    
                    let unit = (product["nutriments_unit"] as? String) ?? "g" // Fallback auf "g"
                    let kcal = (product["nutriments"] as? [String: Any])?["energy-kcal_100g"] as? Int16 ?? 10
                    let fat = (product["nutriments"] as? [String: Any])?["fat_100g"] as? Double ?? 0.0
                    let carbohydrate = (product["nutriments"] as? [String: Any])?["carbohydrates_100g"] as? Double ?? 0.0
                    let protein = (product["nutriments"] as? [String: Any])?["proteins_100g"] as? Double ?? 0.0
                    
                    // Creates Food Item, see struct below
                    return FoodItem(
                        name: "\(brand) \(name)",
                        unit: unit,
                        defaultQuantity: 100,
                        kcal: kcal,
                        fat: Float(fat),
                        carbohydrate: Float(carbohydrate),
                        protein: Float(protein)
                    )
                }
                
                DispatchQueue.main.async {
                    self.products = foodItems // Update of UI
                }
            } catch {
                print("JSON Parsing error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.products = []
                }
            }
        }
        
        task.resume()
    }
    
    func isExisting(uniqueID: String) -> Bool {
        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uniqueID == %@", uniqueID)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Fehler bei der Duplikatsprüfung: \(error.localizedDescription)")
            return false
        }
    }
    
    func OpenFoodFactsFoodToDB(name: String, defaultQuantity: Float, unit: String, calories: Int16, carbs: Float, protein: Float, fat: Float, daytime: Int16, quantity: Float, selectedDate: Date) {
        
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
                food?.defaultQuantity = defaultQuantity
                food?.unit = unit
                food?.kcal = calories
                food?.carbohydrate = carbs
                food?.protein = protein
                food?.fat = fat
                food?.uniqueID = uniqueID
                food?.lastUsed = Date()
                print("Neues Lebensmittel wurde erstellt: \(name)")
            }
        } catch {
            print("Fehler beim Abrufen von Lebensmitteln: \(error.localizedDescription)")
            return
        }
        
        // Neues TrackedFood-Objekt erstellen
        guard let food = food else {
            print("Fehler: Lebensmittel konnte nicht erstellt oder abgerufen werden.")
            return
        }
        
        let trackedFood = TrackedFood(context: context)
        trackedFood.date = selectedDate
        trackedFood.daytime = daytime
        trackedFood.quantity = quantity
        trackedFood.food = food
        
        // Speichern in DB
        do {
            try context.save()
            print("Lebensmittel erfolgreich aktualisiert (lastUsed) und in TrackedFood gespeichert")
        } catch {
            print("Fehler beim Speichern: \(error.localizedDescription)")
        }
    }
}


struct FoodItem: Identifiable {
    let id = UUID()
    let name: String
    let unit: String
    let defaultQuantity: Float
    let kcal: Int16
    let fat: Float
    let carbohydrate: Float
    let protein: Float
}
