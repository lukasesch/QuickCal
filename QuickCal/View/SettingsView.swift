//
//  SettingsView.swift
//  QuickCal
//
//  Created by Lukas Esch on 31.10.24.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("onboarding") private var onboardingDone = false
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var mainViewModel: MainViewModel
    @EnvironmentObject var createPanelViewModel: CreatePanelViewModel
    
    var body: some View {
        VStack() {
            Button(action: {
                createPanelViewModel.createFood(name: "Apfel", defaultQuantity: "1", unit: "stück", calories: "52", carbs: "14", protein: "0.3", fat: "0.2")
                createPanelViewModel.createFood(name: "Banane", defaultQuantity: "1", unit: "stück", calories: "89", carbs: "23", protein: "1.1", fat: "0.3")
                createPanelViewModel.createFood(name: "Hähnchenbrust", defaultQuantity: "100", unit: "g", calories: "165", carbs: "0", protein: "31", fat: "3.6")
                createPanelViewModel.createFood(name: "Reis", defaultQuantity: "100", unit: "g", calories: "130", carbs: "28", protein: "2.4", fat: "0.3")
                createPanelViewModel.createFood(name: "Olivenöl", defaultQuantity: "5", unit: "ml", calories: "119", carbs: "0", protein: "0", fat: "13.5")
            }) {
                Text("Create Dummy Food Entries")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            Divider()
            Button(action: {
                settingsViewModel.deleteAllEntries(for: "User")
                settingsViewModel.deleteAllEntries(for: "Kcal")
                
                onboardingDone = false
            }) {
                Text("Reset Profile")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            Button(action: {
                settingsViewModel.deleteAllEntries(for: "TrackedFood")
                mainViewModel.fetchTrackedFood()
                mainViewModel.updateData()
            }) {
                Text("Reset Food Entries")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            Button(action: {
                settingsViewModel.deleteAllEntries(for: "Food")
                settingsViewModel.deleteAllEntries(for: "TrackedFood")
                mainViewModel.fetchTrackedFood()
                mainViewModel.updateData()
            }) {
                Text("Reset All Food-Related Entries")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    SettingsView()
        .environment(\.managedObjectContext, context)
        .environmentObject(SettingsViewModel(context: context))
}
