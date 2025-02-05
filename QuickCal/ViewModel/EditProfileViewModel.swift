//
//  EditProfileViewModel.swift
//  QuickCal
//
//  Created by Lukas Esch on 05.02.25.
//

import Foundation
import CoreData

class EditProfileViewModel: ObservableObject {
    
    @Published var user: User?
    @Published var errorMessage: ErrorMessage?
    
    private let context: NSManagedObjectContext
    private let mainViewModel: MainViewModel
    
    init(context: NSManagedObjectContext, mainViewModel: MainViewModel) {
        self.context = context
        self.mainViewModel = mainViewModel
        fetchUser()
    }
    
    struct ErrorMessage: Identifiable {
        let id = UUID()
        let message: String
    }
    
    private func fetchUser() {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.fetchLimit = 1  // Nur den ersten User holen
        
        do {
            user = try context.fetch(request).first
        } catch {
            print("Fehler beim Abrufen des Benutzers: \(error.localizedDescription)")
        }
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
            errorMessage = nil
            print("Benutzer aktualisiert")
        } catch {
            errorMessage = ErrorMessage(message: "Daten konnten nicht gespeichert werden. Bitte versuche es erneut.")
            print("Benutzer konnte nicht gespeichert werden: \(error.localizedDescription)")
        }
    }
}
