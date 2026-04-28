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
    @Published var products: [FoodItem] = []
    @Published var isLoading: Bool = false
    private let context: NSManagedObjectContext
    private var currentTask: URLSessionDataTask?
    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func cancelSearch() {
        currentTask?.cancel()
        currentTask = nil
        isLoading = false
        products.removeAll()
    }

    func search(text query: String) {
        print("Search initiated for: \(query)")
        currentTask?.cancel()
        isLoading = true

        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let fields = "product_name,brands,nutriments,serving_quantity_unit,product_quantity_unit"
        let urlString = "https://de.openfoodfacts.org/cgi/search.pl?search_terms=\(encoded)&fields=\(fields)&page_size=30&action=process&json=1"
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            isLoading = false
            return
        }

        print("Requesting URL: \(url)")

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                if (error as NSError).code == NSURLErrorCancelled { return }
                print("Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.products = []
                    self.isLoading = false
                }
                return
            }
            
            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    self.products = []
                    self.isLoading = false
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
                        self.isLoading = false
                    }
                    return
                }
                
                // Convert to FoodItems
                let foodItems = productsArray.compactMap { product -> FoodItem? in
                    // Specify data from json
                    let brand = product["brands"] as? String ?? "Unbekannte Marke"
                    let name = product["product_name"] as? String ?? "Unbekanntes Produkt"
                    
                    var unit = "g" // Standard
                    if let servingQuantityUnit = product["serving_quantity_unit"] as? String {
                        unit = servingQuantityUnit
                    } else if let servingSize = product["product_quantity_unit"] as? String {
                        if servingSize.lowercased().contains("ml") {
                            unit = "ml"
                        } else if servingSize.lowercased().contains("g") {
                            unit = "g"
                        }
                    }
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
                    self.isLoading = false
                }
            } catch {
                print("JSON Parsing error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.products = []
                    self.isLoading = false
                }
            }
        }
        
        currentTask = task
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
    
    @discardableResult
    func addToTracker(item: FoodItem, quantityString: String, daytime: Int16, date: Date) -> Bool {
        guard let q = Float(quantityString.replacingOccurrences(of: ",", with: ".")) else {
            return false
        }
        let multiplier = q / max(item.defaultQuantity, 0.0001)

        let hashString = "\(item.name)\(item.defaultQuantity)\(item.unit)\(item.kcal)\(item.carbohydrate)\(item.protein)\(item.fat)"
        let hash = SHA256.hash(data: Data(hashString.utf8))
        let uniqueID = hash.compactMap { String(format: "%02x", $0) }.joined()

        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uniqueID == %@", uniqueID)

        var food: Food?
        do {
            if let existing = try context.fetch(fetchRequest).first {
                food = existing
                food?.lastUsed = Date()
            } else {
                food = Food(context: context)
                food?.name = item.name
                food?.defaultQuantity = item.defaultQuantity
                food?.unit = item.unit
                food?.kcal = item.kcal
                food?.carbohydrate = item.carbohydrate
                food?.protein = item.protein
                food?.fat = item.fat
                food?.uniqueID = uniqueID
                food?.lastUsed = Date()
            }
        } catch {
            print("Fehler beim Abrufen von Lebensmitteln: \(error.localizedDescription)")
            return false
        }

        guard let food = food else { return false }

        let trackedFood = TrackedFood(context: context)
        trackedFood.date = date
        trackedFood.daytime = daytime
        trackedFood.quantity = multiplier
        trackedFood.food = food

        do {
            try context.save()
            return true
        } catch {
            print("Fehler beim Speichern: \(error.localizedDescription)")
            return false
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
