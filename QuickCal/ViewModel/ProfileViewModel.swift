//
//  ProfileViewModel.swift
//  QuickCal
//
//  Created by Lukas Esch on 10.10.24.
//

import Foundation
import CoreData

final class ProfileViewModel: ObservableObject {
    @Published var user: User?
    
    func updateUser(context: NSManagedObjectContext, gender: String, name: String, age: String, weight: String, height: String, bodyFat: String?, activityLevel: String, goal: String) {
        
        //User erstellen oder aktualisieren
        if user == nil {
            user = User(context: context)
        }
        
        user?.gender = gender
        user?.name = name
        
        if let ageInt = Int16(age) {
            user?.age = ageInt
        }
        
        if let weightFloat = Float(weight) {
            user?.weight = weightFloat
        }
        
        if let heightInt = Int16(height) {
            user?.height = heightInt
        }
        
        if let bodyFatString = bodyFat, let bodyFatFloat = Float(bodyFatString) {
            user?.bodyfat = bodyFatFloat
        }
        
        if activityLevel == "wenig" {
            user?.activity = 1.3
        } else if activityLevel == "etwas" {
            user?.activity = 1.5
        } else if activityLevel == "aktiv" {
            user?.activity = 1.7
        } else if activityLevel == "sehr aktiv" {
            user?.activity = 1.9
        }
        
        if goal == "abnehmen" {
            user?.goal = 0
        } else if goal == "halten" {
            user?.goal = 1
        } else if goal == "zunehmen" {
            user?.goal = 2
        }
        
        
        //Speichern
        do {
            try context.save()
        } catch {
            print("Benutzer konnte nicht gespeichert werden: \(error.localizedDescription)")
        }
    }
    
    
    
}
