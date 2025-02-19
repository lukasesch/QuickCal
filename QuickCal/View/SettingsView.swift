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
    @EnvironmentObject var createPanelViewModel: CreateFoodPanelViewModel
    
    var body: some View {
        NavigationStack {
            VStack() {
                List {
                    Section {
                        NavigationLink(destination: EditProfileView()) {
                            Label("Profil & Ziel bearbeiten", systemImage: "person")
                        }
                        NavigationLink(destination: CalorieMacroView()) {
                            Label("Kalorien & Makronährstoffe anpassen", systemImage: "slider.vertical.3")
                        }
                        NavigationLink(destination: AdvancedSettingsView()) {
                            Label("Datenverwaltung", systemImage: "gearshape")
                        }
                        NavigationLink(destination: HelpView()) {
                            Label("Hilfe", systemImage: "questionmark.circle")
                        }
                        NavigationLink(destination: AboutQuickCalView()) {
                            Label("Über QuickCalorie", systemImage: "info.circle")
                        }
                    }
                    Spacer()
                    Section {
                        HStack {
                            Spacer()
                            VStack {
                                Text("© 2025 Lukas Esch. Alle Rechte vorbehalten.")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                Text("QuickCalorie Version 1.0.0")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                    }
                }
                .listStyle(.plain)
            }
            
            .padding([.top, .trailing])
            .navigationTitle("Einstellungen")
        }
        
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    SettingsView()
        .environment(\.managedObjectContext, context)
        .environmentObject(SettingsViewModel(context: context))
        .environmentObject(OpenFoodFactsViewModel(context: context))
}
