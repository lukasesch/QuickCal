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
    @Published var navigateToMainView = false
    @Published var errorMessage: ErrorMessage?
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    struct ErrorMessage: Identifiable {
        let id = UUID()
        let message: String
    }
    
    func validateInput(name: String, age: String, weight: String, height: String) -> Bool {
        guard !name.isEmpty,
              let _ = Int(age),
              let _ = Float(weight.replacingOccurrences(of: ",", with: ".")),
              let _ = Int(height)
        else {
            errorMessage = ErrorMessage(message: "Bitte alle Felder ausfüllen")
            return false
        }
        errorMessage = nil
        return true
    }
    
    func updateUser(gender: String, name: String, age: String, weight: String, height: String, bodyFat: String?, activityLevel: String, goal: String) {
        
        //User erstellen oder aktualisieren
        if user == nil {
            user = User(context: context)
        }
        
        user?.gender = gender
        user?.name = name
        
        if let ageInt = Int16(age) {
            user?.age = ageInt
        }
        
        if let weightFloat = Float(weight.replacingOccurrences(of: ",", with: ".")) {
            user?.weight = weightFloat
        }
        
        if let heightInt = Int16(height) {
            user?.height = heightInt
        }
        
        if let bodyFatString = bodyFat, let bodyFatFloat = Float(bodyFatString.replacingOccurrences(of: ",", with: ".")) {
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
            navigateToMainView = true
            errorMessage = nil
            print("Benutzer gespeichert")
        } catch {
            errorMessage = ErrorMessage(message: "Daten konnten nicht gespeichert werden. Bitte versuche es erneut.")
            print("Benutzer konnte nicht gespeichert werden: \(error.localizedDescription)")
        }
    }
    
    
    
}
