//
//  SettingsVideoModel.swift
//  QuickCal
//
//  Created by Lukas Esch on 31.10.24.
//

import Foundation
import CoreData

class SettingsViewModel: ObservableObject {
    private let context: NSManagedObjectContext
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func deleteAllEntries(for entityName: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        do {
            let entries = try context.fetch(fetchRequest) as? [NSManagedObject] ?? []
            
            // Lösche jeden Eintrag und wende die Cascade-Delete-Regel an
            for entry in entries {
                context.delete(entry)
            }
            
            try context.save()
            print("All \(entityName)-Entitites wurden gelöscht, einschließlich der verknüpften Einträge gemäß der Cascade-Regel.")
        } catch {
            print("Fehler beim Löschen der Einträge in \(entityName): \(error)")
        }
    }
}
