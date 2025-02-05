//
//  AdvancedSettingsView.swift
//  QuickCal
//
//  Created by Lukas Esch on 05.02.25.
//

import SwiftUI

struct AdvancedSettingsView: View {
    @AppStorage("onboarding") private var onboardingDone = false
    @EnvironmentObject var advancedSettingsViewModel: AdvancedSettingsViewModel
    @EnvironmentObject var mainViewModel: MainViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            // Reset-Buttons
            VStack() {
                
                // Reset Profile Button
                Button(action: {
                    advancedSettingsViewModel.deleteAllEntries(for: "User")
                    advancedSettingsViewModel.deleteAllEntries(for: "Kcal")
                    onboardingDone = false
                }) {
                    Label("Profil zurücksetzen", systemImage: "person.crop.circle.badge.minus")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                // Reset Food Entries Button
                Button(action: {
                    advancedSettingsViewModel.deleteAllEntries(for: "TrackedFood")
                    mainViewModel.fetchTrackedFood()
                    mainViewModel.updateData()
                }) {
                    Label("Getrackte Lebensmittel zurücksetzen", systemImage: "trash")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                // Reset All Food Entries Button
                Button(action: {
                    advancedSettingsViewModel.deleteAllEntries(for: "Food")
                    advancedSettingsViewModel.deleteAllEntries(for: "Meal")
                    advancedSettingsViewModel.deleteAllEntries(for: "MealFood")
                    advancedSettingsViewModel.deleteAllEntries(for: "TrackedFood")
                    mainViewModel.fetchTrackedFood()
                    mainViewModel.updateData()
                }) {
                    Label("Alle Lebensmittel-Daten zurücksetzen", systemImage: "exclamationmark.triangle")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .frame(maxWidth: .infinity)
                }
                
                // Reset everything
                Button(action: {
                    advancedSettingsViewModel.deleteAllEntries(for: "Food")
                    advancedSettingsViewModel.deleteAllEntries(for: "Meal")
                    advancedSettingsViewModel.deleteAllEntries(for: "MealFood")
                    advancedSettingsViewModel.deleteAllEntries(for: "TrackedFood")
                    advancedSettingsViewModel.deleteAllEntries(for: "User")
                    advancedSettingsViewModel.deleteAllEntries(for: "Kcal")
                    PersistenceController.deletePersistentStore()
                    onboardingDone = false
                    exit(0)
                }) {
                    Label("App zurücksetzen", systemImage: "exclamationmark.triangle")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .frame(maxWidth: .infinity)
                }

                Divider()
                    .padding(.top)
                
                // Hinweis
                Text("⚠️ **Achtung:** Das Zurücksetzen löscht alle betroffenen Daten unwiderruflich.")
                    .font(.footnote)
                    .foregroundColor(.red)

                
                Spacer()
            }
            
        }
        .navigationTitle("Datenverwaltung")
        .padding()
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    AdvancedSettingsView()
        .environment(\.managedObjectContext, context)
        .environmentObject(AdvancedSettingsViewModel(context: context))
        .environmentObject(OpenFoodFactsViewModel(context: context))
}
