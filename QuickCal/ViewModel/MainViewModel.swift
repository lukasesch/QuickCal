//
//  MainViewModel.swift
//  QuickCal
//
//  Created by Lukas Esch on 10.10.24.
//

import Foundation

class MainViewModel: ObservableObject {
    @Published var dailyCalories: Double = 0
    
    func calculateCalories(for user: UserModel) {
        if user.gender.isEqual("männlich") {
            // Männlich: Grundumsatz (kcal/Tag) = 66,47 + (13,7 × Gewicht in kg) + (5,0 × Größe in cm) − (6,8 × Alter in Jahren)
            let weightFactor = 13.7 * Double(user.weight)
            let heightFactor = 5.0 * Double(user.height)
            let ageFactor = 6.8 * Double(user.age)
            dailyCalories = 66.47 + weightFactor + heightFactor - ageFactor
        } else if user.gender.isEqual("weiblich") {
            // Weiblich: Grundumsatz (kcal/Tag) = 655,1 + (9,6 × Gewicht in kg) + (1,8 × Größe in cm) − (4,7 × Alter in Jahren)
            let weightFactor = 9.6 * Double(user.weight)
            let heightFactor = 1.8 * Double(user.height)
            let ageFactor = 4.7 * Double(user.age)
            dailyCalories = 655.1 + weightFactor + heightFactor - ageFactor
        } else {
            print("Error in calculating Calories")
        }
    }
}
