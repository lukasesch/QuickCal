//
//  CalorieMacroViewModel.swift
//  QuickCal
//
//  Created by Lukas Esch on 06.02.25.
//

import Foundation
import CoreData

class CalorieMacroViewModel: ObservableObject {
    @Published var calories: Double = 2000 {
        didSet {
            updateGrams()
        }
    }
    
    @Published var carbsPercentage: Double = 40 {
        didSet {
            updateGrams()
        }
    }
    
    @Published var proteinsPercentage: Double = 30 {
        didSet {
            updateGrams()
        }
    }
    
    @Published var fatsPercentage: Double = 30 {
        didSet {
            updateGrams()
        }
    }
    
    @Published var carbsGrams: Int = 0
    @Published var proteinsGrams: Int = 0
    @Published var fatsGrams: Int = 0
    
    @Published var errorMessage: String? = nil
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchLatestKcalEntry()
    }
    
    func fetchLatestKcalEntry() {
        let fetchRequest: NSFetchRequest<Kcal> = Kcal.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Kcal.date, ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            if let latestEntry = try context.fetch(fetchRequest).first {
                self.calories = ceil(latestEntry.kcalGoal) // Rundet nach oben
                self.carbsGrams = Int(ceil(Double(latestEntry.carbsGoal)))
                self.proteinsGrams = Int(ceil(Double(latestEntry.proteinGoal)))
                self.fatsGrams = Int(Double(latestEntry.fatGoal).rounded())
                print("Geladen: \(calories)   \(carbsGrams)   \(proteinsGrams)   \(fatsGrams)")
                updatePercentages()
                print("Geladen Prozente: \(calories)   \(carbsPercentage)   \(proteinsPercentage)   \(fatsPercentage)")
            }
        } catch {
            print("Fehler beim Laden: \(error.localizedDescription)")
        }
    }
    
    func updatePercentages() {
        guard calories > 0 else { return }
        
        // Berechnung der Kalorien aus jedem Makronährstoff
        let carbsCalories = Double(carbsGrams) * 4.0
        let proteinsCalories = Double(proteinsGrams) * 4.0
        let fatsCalories = Double(fatsGrams) * 9.0
        
        // Berechnung der prozentualen Anteile
        carbsPercentage = Double(round((carbsCalories / Double(calories)) * 100.0))
        proteinsPercentage = Double(round((proteinsCalories / Double(calories)) * 100.0))
        fatsPercentage = Double(round((fatsCalories / Double(calories)) * 100.0))
    }
    
    func updateGrams() {
        carbsGrams = Int((calories * (carbsPercentage / 100) / 4).rounded())
        proteinsGrams = Int((calories * (proteinsPercentage / 100) / 4).rounded())
        fatsGrams = Int((calories * (fatsPercentage / 100) / 9).rounded())
    }
    
    func saveCalorieData() {
        let totalPercentage = carbsPercentage + proteinsPercentage + fatsPercentage
        
        guard totalPercentage == 100 else {
            errorMessage = "Die Summe der Makronährstoff-Prozente muss 100 % ergeben."
            return
        }
        
        let newEntry = Kcal(context: context)
        newEntry.kcalGoal = calories
        newEntry.carbsGoal = Double(carbsGrams)
        newEntry.proteinGoal = Double(proteinsGrams)
        newEntry.fatGoal = Double(fatsGrams)
        newEntry.date = Date()
        
        do {
            try context.save()
            print("Gespeichert: \(newEntry.kcalGoal)   \(newEntry.carbsGoal)   \(newEntry.proteinGoal)   \(newEntry.fatGoal)")
            errorMessage = nil
            print("Daten gespeichert.")
        } catch {
            errorMessage = "Fehler beim Speichern der Daten: \(error.localizedDescription)"
        }
    }
}
