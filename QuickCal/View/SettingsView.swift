//
//  SettingsView.swift
//  QuickCal
//
//  Created by Lukas Esch on 31.10.24.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("onboarding") private var onboardingDone = false
    @EnvironmentObject var settingsViewModel: SettingsVideoModel
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        VStack() {
            Button(action: {
                settingsViewModel.deleteAllEntries(for: "Kcal", in: viewContext)
                onboardingDone = false
            }) {
                Text("Reset Profile")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsVideoModel())
}
