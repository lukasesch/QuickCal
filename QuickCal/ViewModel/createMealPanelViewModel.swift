//
//  createMealPanelViewModel.swift
//  QuickCal
//
//  Created by Lukas Esch on 20.01.25.
//

import Foundation

class CreateMealPanelViewModel: ObservableObject {
    @Published var mealFood: [TrackedFood] = []
    
    @Published var kcalTotal: Double = 0
    @Published var carbsTotal: Double = 0
    @Published var proteinTotal: Double = 0
    @Published var fatTotal: Double = 0
    
    func deleteTrackedFoodItem(at offsets: IndexSet) {
        
    }
}
