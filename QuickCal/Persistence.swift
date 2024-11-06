//
//  Persistence.swift
//  QuickCal
//
//  Created by Lukas Esch on 09.10.24.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        result.createPreviewData()
        return result
    }()
    
    private func createPreviewData() {
        //Create User Entry
        //let viewModel = MainViewModel()
        let viewContext = container.viewContext
        let exampleUser = User(context: viewContext)
        exampleUser.name = "Lukas"
        exampleUser.age = 30
        exampleUser.weight = 75
        exampleUser.height = 180
        exampleUser.activity = 1.3
        
        //Create Food Entry
        let exampleFood = Food(context: viewContext)
        exampleFood.name = "Banana"
        exampleFood.kcal = 89
        exampleFood.protein = 1.1
        exampleFood.fat = 0.3
        exampleFood.carbohydrate = 23.0
        exampleFood.defaultQuantity = 100.0
        exampleFood.unit = "g"
        //Should run itself because of .onAppear modifier?
        //viewModel.checkAndCalculateDailyCalories(context: viewContext)
        
        // Create TrackedFood Entry
        let exampleTrackedFood = TrackedFood(context: viewContext)
        exampleTrackedFood.date = Date() // Setzt das aktuelle Datum
        exampleTrackedFood.daytime = 0 // 0 könnte für Frühstück stehen
        exampleTrackedFood.quantity = 150.0 // Beispielmenge in Gramm
        
        // Verknüpfe TrackedFood mit Food und User
        exampleTrackedFood.food = exampleFood
        exampleTrackedFood.user = exampleUser
        
        // Save context to persist data for the preview
        do {
            try viewContext.save()
        } catch {
            print("Failed to save preview data: \(error)")
        }
    }

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "QuickCal")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
                // Optionally: notify the user or handle errors gracefully
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    //For Debugging - deletes persistant storage
    func deletePersistentStore() {
        if let storeURL = container.persistentStoreDescriptions.first?.url {
            do {
                try container.persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
                print("Persistent store deleted.")
            } catch {
                print("Failed to delete persistent store: \(error)")
            }
        }
    }
}
