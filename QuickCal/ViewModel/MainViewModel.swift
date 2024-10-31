//
//  MainViewModel.swift
//  QuickCal
//
//  Created by Lukas Esch on 10.10.24.
//

import Foundation
import CoreData

class MainViewModel: ObservableObject {
    @Published var kcalGoal: Double = 0
    @Published var kcalReached: Double = 0
    @Published var carbsGoal: Int = 0
    @Published var carbsReached: Int = 0
    @Published var proteinGoal: Int = 0
    @Published var proteinReached: Int = 0
    @Published var fatGoal: Int = 0
    @Published var fatReached: Int = 0
    @Published var user: User?
        
    func fetchUser(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        
        do {
            let users = try context.fetch(fetchRequest)
            //Last user
            //App needs to check if user already exists - for now while testing it always gets the last user
            if let lastUser = users.last {
                self.user = lastUser
                //calculateCalories(for: lastUser)
            } else {
                print("No user found")
            }
        } catch {
            print("Failed to fetch user: \(error)")
        }
    }
    
    func checkAndCalculateDailyCalories(context: NSManagedObjectContext) {
        // Current Date
        let today = Calendar.current.startOfDay(for: Date())
        
        // Check if there is already a Kcal entry in the DB for current Day
        let fetchRequest: NSFetchRequest<Kcal> = Kcal.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date == %@", today as NSDate)
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.isEmpty {
                // No entry there, so get user and calculate Kcal entry
                fetchUser(context: context)
                if let user = user {
                    calculateKcal(for: user)
                    saveKcalDB(context: context, date: today, calories: kcalGoal, carbs: carbsGoal, protein: proteinGoal, fat: fatGoal)
                }
            } else {
                // Get data from current day Kcal entry
                kcalGoal = results.first?.kcalGoal ?? 0
                kcalReached = results.first?.kcalReached ?? 0
                carbsGoal = Int(results.first?.carbsGoal ?? 0)
                carbsReached = Int(results.first?.carbsReached ?? 0)
                proteinGoal = Int(results.first?.proteinGoal ?? 0)
                proteinReached = Int(results.first?.proteinReached ?? 0)
                fatGoal = Int(results.first?.fatGoal ?? 0)
                fatReached = Int(results.first?.fatReached ?? 0)
            }
        } catch {
            print("Fehler beim Abrufen der Kalorien für heute: \(error)")
        }
    }
    
    func calculateKcal(for user: User) {
        guard let gender = user.gender else {
            print("Error: Gender is nil")
            return
        }
        
        if gender == "männlich" {
            // Männlich: Grundumsatz (kcal/Tag) = 66,47 + (13,7 × Gewicht in kg) + (5,0 × Größe in cm) − (6,8 × Alter in Jahren)
            let weightFactor = 13.7 * Double(user.weight)
            let heightFactor = 5.0 * Double(user.height)
            let ageFactor = 6.8 * Double(user.age)
            kcalGoal = Double(user.activity) * (66.47 + weightFactor + heightFactor - ageFactor)
            
        } else if gender == "weiblich" {
            // Weiblich: Grundumsatz (kcal/Tag) = 655,1 + (9,6 × Gewicht in kg) + (1,8 × Größe in cm) − (4,7 × Alter in Jahren)
            let weightFactor = 9.6 * Double(user.weight)
            let heightFactor = 1.8 * Double(user.height)
            let ageFactor = 4.7 * Double(user.age)
            kcalGoal = Double(user.activity) * (655.1 + weightFactor + heightFactor - ageFactor)
        } else {
            print("Error in calculating Calories")
        }
        
        if user.goal == 0 {
            kcalGoal = kcalGoal - 250
        } else if user.goal == 1 {
            kcalGoal = kcalGoal
        } else if user.goal == 2 {
            kcalGoal = kcalGoal + 250
        } else {
            print("Error: goal string has wrong value")
        }
        
        //Calculate Macros (rounded as accuracy not needed)
        carbsGoal = Int((kcalGoal * 0.40 / 4).rounded())
        proteinGoal = Int((kcalGoal * 0.30 / 4).rounded())
        fatGoal = Int((kcalGoal * 0.30 / 9).rounded())
    }
    
    func saveKcalDB(context: NSManagedObjectContext, date: Date, calories: Double, carbs: Int, protein: Int, fat: Int) {
        let newKcal = Kcal(context: context)
        newKcal.date = date
        newKcal.kcalGoal = calories
        newKcal.kcalReached = 0 // Set to 0 again as new day in Kcal DB
        newKcal.carbsGoal = Int16(carbs)
        newKcal.carbsReached = 0
        newKcal.proteinGoal = Int16(protein)
        newKcal.proteinReached = 0
        newKcal.fatGoal = Int16(fat)
        newKcal.fatReached = 0

        
        do {
            try context.save()
            print("Kalorien für heute gespeichert")
        } catch {
            print("Fehler beim Speichern der Kalorien: \(error)")
        }
    }
}
