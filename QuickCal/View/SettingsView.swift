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
    
    var body: some View {
        VStack() {
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
                settingsViewModel.deleteAllEntries(for: "Food")
                
            }) {
                Text("Reset Food Entries")
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
