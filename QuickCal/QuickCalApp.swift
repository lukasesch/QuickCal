//
//  QuickCalApp.swift
//  QuickCal
//
//  Created by Lukas Esch on 09.10.24.
//

import SwiftUI

@main
struct QuickCalApp: App {
    @AppStorage("onboarding") private var onboardingDone = false
    let persistenceController = PersistenceController.shared
    //var profileViewModel = ProfileViewModel() //Sinnlos?

    var body: some Scene {
        WindowGroup {
            if onboardingDone == true {
                MainView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(MainViewModel())
                    .environmentObject(SettingsVideoModel())
            } else {
                WelcomeView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(MainViewModel())
                    .environmentObject(SettingsVideoModel())
            }
            
        }
    }
}
