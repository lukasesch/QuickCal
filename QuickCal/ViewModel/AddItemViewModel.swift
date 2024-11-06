//
//  AddItemViewModel.swift
//  QuickCal
//
//  Created by Lukas Esch on 05.11.24.
//

import Foundation
import CoreData

class AddItemViewModel: ObservableObject {
    @Published var foodItems: [Food] = []
    
    //Load Context and fetch Food items
    private let context: NSManagedObjectContext
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchFoodItems()
    }
    
    func fetchFoodItems() {
        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Food.name, ascending: true)]
        
        do {
            foodItems = try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch food items: \(error)")
        }
    }
    
    
}
