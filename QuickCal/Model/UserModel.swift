//
//  UserModel.swift
//  QuickCal
//
//  Created by Lukas Esch on 10.10.24.
//

import Foundation

struct UserModel {
    var gender: String // maennlich / weiblich
    var name: String
    var age: Int
    var weight: Float
    var height: Int
    var bodyFat: Float?
    var activityLevel: Float // Bereits Dezimalzahl zur Berechnung
    var goal: String // abnehmen / halten / zunehmen
}
