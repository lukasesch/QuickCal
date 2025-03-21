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

    var body: some Scene {
        WindowGroup {
            if onboardingDone == true {
                MainView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(ProfileViewModel(context: persistenceController.container.viewContext))
                    .environmentObject(MainViewModel(context: persistenceController.container.viewContext))
                    .environmentObject(SettingsViewModel(context: persistenceController.container.viewContext))
                    .environmentObject(AddTrackedFoodViewModel(context: persistenceController.container.viewContext))
                    .environmentObject(CreateFoodPanelViewModel(context: persistenceController.container.viewContext))
                    .environmentObject(CreateMealPanelViewModel(context: persistenceController.container.viewContext))
                    .environmentObject(CreateMealIngredientsViewModel())
                    .environmentObject(OpenFoodFactsViewModel(context: persistenceController.container.viewContext))
                    .environmentObject(BarCodeViewModel(context: persistenceController.container.viewContext))
                    .environmentObject(AdvancedSettingsViewModel(context: persistenceController.container.viewContext))
                    .environmentObject(CalorieMacroViewModel(context: persistenceController.container.viewContext))
                    .environmentObject(EditProfileViewModel(context: persistenceController.container.viewContext, mainViewModel: MainViewModel(context: persistenceController.container.viewContext)))
            } else {
                WelcomeView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(ProfileViewModel(context: persistenceController.container.viewContext))
                    .environmentObject(MainViewModel(context: persistenceController.container.viewContext))
                    .environmentObject(SettingsViewModel(context: persistenceController.container.viewContext))
                    .environmentObject(AddTrackedFoodViewModel(context: persistenceController.container.viewContext))
                    .environmentObject(CreateFoodPanelViewModel(context: persistenceController.container.viewContext))
                    .environmentObject(CreateMealPanelViewModel(context: persistenceController.container.viewContext))
                    .environmentObject(CreateMealIngredientsViewModel())
                    .environmentObject(OpenFoodFactsViewModel(context: persistenceController.container.viewContext))
                    .environmentObject(BarCodeViewModel(context: persistenceController.container.viewContext))
                    .environmentObject(AdvancedSettingsViewModel(context: persistenceController.container.viewContext))
                    .environmentObject(CalorieMacroViewModel(context: persistenceController.container.viewContext))
                    .environmentObject(EditProfileViewModel(context: persistenceController.container.viewContext, mainViewModel: MainViewModel(context: persistenceController.container.viewContext)))
            }
            
        }
    }
}
