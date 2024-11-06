//
//  AddTrackedFoodViewModel.swift
//  QuickCal
//
//  Created by Lukas Esch on 05.11.24.
//

import SwiftUI
import CoreData

class AddTrackedFoodViewModel: ObservableObject {
    private let context: NSManagedObjectContext
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchFoodItems()
    }
    
    @Published var foodItems: [Food] = []
    
    func fetchFoodItems() {
        let request: NSFetchRequest<Food> = Food.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Food.name, ascending: true)]
        
        do {
            foodItems = try context.fetch(request)
        } catch {
            print("Failed to fetch food items: \(error)")
        }
    }
    
    func addTrackedFood(food: Food, quantity: Float, daytime: Int16) {
        // 1. Neue Instanz von TrackedFood erstellen
        let trackedFood = TrackedFood(context: context)
        
        // 2. Setze die Attribute für TrackedFood
        trackedFood.date = Date()  // Setzt das aktuelle Datum
        trackedFood.daytime = daytime  // Setze die Tageszeit, z.B. 0 = Frühstück
        trackedFood.quantity = quantity  // Setze die Menge
        
        // 3. Setze die Beziehung zum ausgewählten Food-Objekt
        trackedFood.food = food
        
        // Optional: Setze die Beziehung zum User, falls gewünscht
        // trackedFood.user = currentUser
        
        // 4. Speichere den Kontext, um die Änderungen in Core Data zu persistieren
        do {
            try context.save()
            print("Tracked \(food.name ?? "Unbekannt") saved successfully!")
        } catch {
            print("Failed to save tracked food: \(error)")
        }
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
}
