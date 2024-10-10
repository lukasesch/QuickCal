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
            print(user.age)
        }
        if let weightFloat = Float(weight) {
            user.weight = weightFloat
            print(user.weight)
        }
        if let heightInt = Int(height) {
            user.height = heightInt
            print(user.height)
        }
        if let bodyFatString = bodyFat, let bodyFatFloat = Float(bodyFatString) {
            user.bodyFat = bodyFatFloat
            print(user.bodyFat)
        }
        // Zahlen entsprechen Aktivitätslevel zum berechnen der kcal nach PAL-Werten
        if activityLevel.isEqual("wenig") {
            user.activityLevel = 1.3
            print(user.activityLevel)
        } else if activityLevel.isEqual("etwas") {
            user.activityLevel = 1.5
            print(user.activityLevel)
        } else if activityLevel.isEqual("aktiv") {
            user.activityLevel = 1.7
            print(user.activityLevel)
        } else if activityLevel.isEqual("sehr aktiv") {
            user.activityLevel = 1.9
            print(user.activityLevel)
        }
        user.goal = goal
        print(user.goal)
    }
    
    
    
}
