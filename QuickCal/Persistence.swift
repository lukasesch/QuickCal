//
//  Persistence.swift
//  QuickCal
//
//  Created by Lukas Esch on 09.10.24.
//

import CoreData

class PersistenceController {
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
        exampleTrackedFood.quantity = 1.5 // Beispielmenge in Gramm
        
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
    
    var container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "QuickCal")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { [weak self] (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
            
            // 2. Verwende [weak self] und optionales Chaining
            DispatchQueue.main.async {
                self?.loadDefaultFood(context: self?.container.viewContext ?? NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // Default Food
    func loadDefaultFood(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        
        do {
            let count = try context.count(for: fetchRequest)
            if count == 0 { // Nur laden, wenn noch keine Daten existieren
                let foods = [
                    ("Apfel", 1.0, "stück", 52, 14, 0.3, 0.2),
                    ("Banane", 1.0, "stück", 89, 23, 1.1, 0.3),
                    ("Hähnchenbrust", 100.0, "g", 165, 0, 31, 3.6),
                    ("Reis", 100.0, "g", 130, 28, 2.4, 0.3),
                    ("Olivenöl", 5.0, "ml", 119, 0, 0, 13.5)
                ]
                
                for (name, quantity, unit, kcal, carbs, protein, fat) in foods {
                    let newFood = Food(context: context)
                    newFood.name = name
                    newFood.defaultQuantity = Float(quantity)
                    newFood.unit = unit
                    newFood.kcal = Int16(kcal)
                    newFood.carbohydrate = Float(carbs)
                    newFood.protein = Float(protein)
                    newFood.fat = Float(fat)
                }
                
                try context.save()
                print("Standard-Lebensmittel wurden gespeichert.")
            }
        } catch {
            print("Fehler beim Laden der Standard-Lebensmittel: \(error)")
        }
    }
    
    //For Debugging - deletes persistant storage
    static func deletePersistentStore() {
        if let storeURL = shared.container.persistentStoreDescriptions.first?.url {
            do {
                try shared.container.persistentStoreCoordinator.destroyPersistentStore(
                    at: storeURL,
                    ofType: NSSQLiteStoreType,
                    options: nil
                )
                
                // WICHTIG: Container neu initialisieren
                shared.container = NSPersistentContainer(name: "QuickCal")
                print("Persistent store deleted and reinitialized")
            } catch {
                print("Failed to delete persistent store: \(error)")
            }
        }
    }
}
