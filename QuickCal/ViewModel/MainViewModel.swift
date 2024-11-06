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
    @Published var trackedFood: [TrackedFood] = []
    
    
    private let context: NSManagedObjectContext
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    var kcalProgressPercentage: Double {
        guard kcalGoal > 0 else { return 0 }
        return 1.0 - ((kcalGoal - kcalReached) / kcalGoal)
    }
    var carbsProgressPercentage: Double {
        guard carbsGoal > 0 else { return 0 }
        return 1.0 - ((Double(carbsGoal) - Double(carbsReached)) / Double(carbsGoal))
    }
    var proteinProgressPercentage: Double {
        guard proteinGoal > 0 else { return 0 }
        return 1.0 - ((Double(proteinGoal) - Double(proteinReached)) / Double(proteinGoal))
    }
    var fatProgressPercentage: Double {
        guard fatGoal > 0 else { return 0 }
        return 1.0 - ((Double(fatGoal) - Double(fatReached)) / Double(fatGoal))
    }

    @MainActor
    func fetchOrCreateUser() {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        
        do {
            let users = try context.fetch(fetchRequest)
            //Last user
            //App needs to check if user already exists - for now while testing it always gets the last user
            if let lastUser = users.last {
                self.user = lastUser
            } else {
                print("No user found")
            }
        } catch {
            print("Failed to fetch user: \(error)")
        }
    }
    
    func fetchTrackedFood() {
        let fetchRequest: NSFetchRequest<TrackedFood> = TrackedFood.fetchRequest()
        
        do {
            let trackedFoods = try context.fetch(fetchRequest)
            self.trackedFood = trackedFoods
        } catch {
            print("Failed to fetch tracked food: \(error)")
        }
    }
    
    func trackedFood(forDaytime daytime: Int16) -> [TrackedFood] {
        return trackedFood.filter { $0.daytime == daytime }
    }
    
    @MainActor
    func fetchOrCreateDailyKcal(for date: Date) {
        let fetchRequest: NSFetchRequest<Kcal> = Kcal.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", date as NSDate, Calendar.current.date(byAdding: .day, value: 1, to: date)! as NSDate)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let dailyKcal = results.first {
                assignDailyKcalValues(dailyKcal)
            } else {
                if let user = user {
                    calculateAndSaveDailyKcal(for: user, date: date)
                }
            }
        } catch {
            print("Failed to fetch daily kcal: \(error)")
        }
    }
    
    
    private func assignDailyKcalValues(_ dailyKcal: Kcal) {
        kcalGoal = dailyKcal.kcalGoal
        kcalReached = dailyKcal.kcalReached
        carbsGoal = Int(dailyKcal.carbsGoal)
        carbsReached = Int(dailyKcal.carbsReached)
        proteinGoal = Int(dailyKcal.proteinGoal)
        proteinReached = Int(dailyKcal.proteinReached)
        fatGoal = Int(dailyKcal.fatGoal)
        fatReached = Int(dailyKcal.fatReached)
    }
    
    func calculateAndSaveDailyKcal(for user: User, date: Date) {
        calculateKcal(for: user)
        saveKcalDB(date: date, calories: kcalGoal, carbs: carbsGoal, protein: proteinGoal, fat: fatGoal)
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
    
    func saveKcalDB(date: Date, calories: Double, carbs: Int, protein: Int, fat: Int) {
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
    
    @MainActor
    func checkAndCalculateDailyCalories() {
        // Make sure its the current user
        fetchOrCreateUser()
        // Current Date
        let today = Calendar.current.startOfDay(for: Date())
        fetchOrCreateDailyKcal(for: today)
        
    }
}
