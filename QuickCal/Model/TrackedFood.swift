//
//  TrackedFood+Helpers.swift
//  QuickCal
//

import Foundation

extension TrackedFood {
    var displayName: String {
        food?.name ?? "Unbekannt"
    }

    var totalKcalValue: Float {
        Float(food?.kcal ?? 0) * quantity
    }

    var portionDisplayString: String {
        let amount = quantity * (food?.defaultQuantity ?? 0)
        let unit = food?.unit ?? ""
        return String(format: "%.0f", amount) + (unit.isEmpty ? "" : " \(unit)")
    }
}
