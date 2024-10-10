//
//  ProfileViewModel.swift
//  QuickCal
//
//  Created by Lukas Esch on 10.10.24.
//

import Foundation

final class ProfileViewModel: ObservableObject {
    @Published var user = UserModel(gender: "weiblich", name: "", age: 0, weight: 0.0, height: 0, bodyFat: nil, activityLevel: 0.0, goal: "halten")
    
    func updateUser(gender:String, name:String, age:String, weight:String, height:String, bodyFat:String?, activityLevel:String, goal:String) {
        user.gender = gender
        user.name = name
        if let ageInt = Int(age) {
            user.age = ageInt
        }
        if let weightFloat = Float(weight) {
            user.weight = weightFloat
        }
        if let heightInt = Int(height) {
            user.height = heightInt
        }
        if let bodyFatString = bodyFat, let bodyFatFloat = Float(bodyFatString) {
            user.bodyFat = bodyFatFloat
        }
        // Zahlen entsprechen Aktivitätslevel zum berechnen der kcal nach PAL-Werten
        if activityLevel.isEqual("wenig") {
            user.activityLevel = 1.3
        } else if activityLevel.isEqual("etwas") {
            user.activityLevel = 1.5
        } else if activityLevel.isEqual("aktiv") {
            user.activityLevel = 1.7
        } else if activityLevel.isEqual("sehr aktiv") {
            user.activityLevel = 1.9
        }
        user.goal = goal
    }
    
    
    
}
