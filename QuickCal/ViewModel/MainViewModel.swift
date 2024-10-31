//
//  MainViewModel.swift
//  QuickCal
//
//  Created by Lukas Esch on 10.10.24.
//

import Foundation
import CoreData

class MainViewModel: ObservableObject {
    @Published var dailyCalories: Double = 0
    @Published var user: User?
        
    func fetchUser(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        
        do {
            let users = try context.fetch(fetchRequest)
            //Last user
            //App needs to check if user already exists - for now while testing it always gets the last user
            if let lastUser = users.last {
                self.user = lastUser
                calculateCalories(for: lastUser)
            } else {
                print("No user found")
            }
        } catch {
            print("Failed to fetch user: \(error)")
        }
    }
    
    func checkAndCalculateDailyCalories(context: NSManagedObjectContext) {
        // Heutiges Datum ohne Zeitkomponente
        let today = Calendar.current.startOfDay(for: Date())
        
        // Prüfen, ob bereits ein Eintrag für heute in der `Kcal`-Entität vorhanden ist
        let fetchRequest: NSFetchRequest<Kcal> = Kcal.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date == %@", today as NSDate)
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.isEmpty {
                // Kein Eintrag für heute vorhanden, also berechnen und speichern
                fetchUser(context: context) // Holt den Benutzer, falls nicht bereits gesetzt
                if let user = user {
                    calculateCalories(for: user)
                    saveDailyCalories(context: context, date: today, calories: dailyCalories)
                }
            } else {
                // Eintrag für heute vorhanden, setze dailyCalories
                dailyCalories = results.first?.kcalGoal ?? 0
            }
        } catch {
            print("Fehler beim Abrufen der Kalorien für heute: \(error)")
        }
    }
    
    func calculateCalories(for user: User) {
        guard let gender = user.gender else {
            print("Error: Gender is nil")
            return
        }
        
        if gender == "männlich" {
            // Männlich: Grundumsatz (kcal/Tag) = 66,47 + (13,7 × Gewicht in kg) + (5,0 × Größe in cm) − (6,8 × Alter in Jahren)
            let weightFactor = 13.7 * Double(user.weight)
            let heightFactor = 5.0 * Double(user.height)
            let ageFactor = 6.8 * Double(user.age)
            dailyCalories = Double(user.activity) * (66.47 + weightFactor + heightFactor - ageFactor)
            
        } else if gender == "weiblich" {
            // Weiblich: Grundumsatz (kcal/Tag) = 655,1 + (9,6 × Gewicht in kg) + (1,8 × Größe in cm) − (4,7 × Alter in Jahren)
            let weightFactor = 9.6 * Double(user.weight)
            let heightFactor = 1.8 * Double(user.height)
            let ageFactor = 4.7 * Double(user.age)
            dailyCalories = Double(user.activity) * (655.1 + weightFactor + heightFactor - ageFactor)
        } else {
            print("Error in calculating Calories")
        }
        
        if user.goal == 0 {
            dailyCalories = dailyCalories - 250
        } else if user.goal == 1 {
            dailyCalories = dailyCalories
        } else if user.goal == 2 {
            dailyCalories = dailyCalories + 250
        } else {
            print("Error: goal string has wrong value")
        }
    }
    
    func saveDailyCalories(context: NSManagedObjectContext, date: Date, calories: Double) {
        let newKcal = Kcal(context: context)
        newKcal.date = date
        newKcal.kcalGoal = calories
        newKcal.kcalReached = 0 // Setze `dailykcal_reached` auf 0, da der Tag gerade beginnt
        
        do {
            try context.save()
            print("Kalorien für heute gespeichert")
        } catch {
            print("Fehler beim Speichern der Kalorien: \(error)")
        }
    }
}
