//
//  QuickCalApp.swift
//  QuickCal
//
//  Created by Lukas Esch on 09.10.24.
//

import SwiftUI

@main
struct QuickCalApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
