//
//  AboutQuickCalView.swift
//  QuickCal
//
//  Created by Lukas Esch on 05.02.25.
//

import SwiftUI

struct AboutQuickCalView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Beschreibung
                Text("**QuickCalorie** ist eine Ernährungs-Tracking-App, die eine **einfache und schnelle Möglichkeit** bietet, Lebensmittel und Mahlzeiten zu erfassen.")
                
                Divider()
                
                // Entwicklungsstatus
                Text("🛠 **Entwicklungsphase**")
                    .font(.headline)
                Text("Diese App ist **Teil meines Projektmoduls** im Masterstudiengang Informatik an der Hochschule Trier und befindet sich noch in der Entwicklung. Zukünftige Updates werden neue Funktionen und Verbesserungen bringen.")
                
                Divider()
                
                // OpenFoodFacts-Integration
                Text("🌍 **Datenquelle**")
                    .font(.headline)
                Text("Für Nährwertangaben nutzt QuickCalorie die Open-Source-Datenbank **OpenFoodFacts**. Diese Datenbank enthält eine Vielzahl von Lebensmitteln, die von der Community gepflegt und erweitert werden.")
                
                // Link zu OpenFoodFacts
                Link("Mehr zu OpenFoodFacts", destination: URL(string: "https://world.openfoodfacts.org/")!)
                    .foregroundColor(.blue)
                    .padding(.top, 5)
                
                Divider()
                
                // Feedback
                Text("💡 **Feedback**")
                    .font(.headline)
                Text("Da sich QuickCalorie noch in der Entwicklungsphase befindet, sind **Anregungen und Feedback** jederzeit willkommen! 🚀")
                
                Spacer()
                
                // Copyright & Version
                VStack {
                    Divider()
                    Text("© 2025 Lukas Esch. Alle Rechte vorbehalten.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Text("QuickCalorie Version 1.0.0")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .padding(.top, 10)
            }
            .padding()
        }
        .navigationTitle("Über QuickCalorie")
    }
}

#Preview {
    AboutQuickCalView()
}
