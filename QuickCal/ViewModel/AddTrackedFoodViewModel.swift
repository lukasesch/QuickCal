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
    private var allFoodItems: [Food] = []
    
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
    
    func filterFoodItems(by searchText: String) {
        if searchText.isEmpty {
            foodItems = allFoodItems // Reset to all items if the search is empty
        } else {
            foodItems = allFoodItems.filter { food in
                (food.name?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }
    
    func addTrackedFood(food: Food, quantity: Float, daytime: Int16) {
        let trackedFood = TrackedFood(context: context)
        trackedFood.date = Date()
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
