//
//  SettingsVideoModel.swift
//  QuickCal
//
//  Created by Lukas Esch on 31.10.24.
//

import Foundation
import CoreData

class SettingsVideoModel: ObservableObject {
    
    
    func deleteAllEntries(for entityName: String, in context: NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            print("Alle Einträge in der \(entityName)-Entity wurden gelöscht.")
        } catch {
            print("Fehler beim Löschen der Einträge: \(error)")
        }
    }
}
