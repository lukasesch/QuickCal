//
//  HelpView.swift
//  QuickCal
//
//  Created by Lukas Esch on 05.02.25.
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
               
                // Beschreibung
                Text("QuickCalorie erleichtert dir das Tracking deiner Ernährung mit einer intuitiven Bedienung. Hier erfährst du, wie du die wichtigsten Funktionen nutzt.")
                
                Divider()
                
                // Nährwertübersicht & Tagesziel
                Text("📊 **Tagesziel & Nährwertübersicht**")
                    .font(.headline)
                Text("Die Hauptansicht zeigt dir eine **Übersicht der konsumierten Kalorien, Kohlenhydrate, Proteine und Fette**.")
                Text("▫️ **Fortschrittsbalken:** Visuelle Darstellung deines aktuellen Tagesfortschritts.")
                Text("💡 **Tagesziel anpassen:** Ändere dein Kalorien- und Makroziele jederzeit in den Einstellungen!")
                
                Divider()
                
                // Lebensmittel & Gerichte hinzufügen
                Text("➕ **Lebensmittel & Gerichte hinzufügen**")
                    .font(.headline)
                Text("Tippe auf das **„+“ Symbol**, um neue Einträge zu erstellen. Die Lebensmittel werden automatisch der aktuell ausgewählten Tageszeit hinzugefügt.")
                Text("▫️ **Eigene Lebensmittel:** Manuelle Eingabe von Name, Portion & Nährwerten.")
                Text("▫️ **Eigene Gerichte:** Mehrere Lebensmittel zu einer Mahlzeit kombinieren.")
                Text("▫️ **Open Food Facts:** Lebensmittel aus der Datenbank importieren.")
                Text("▫️ **Barcode-Scan:** Produkte einfach per Strichcode scannen.")
                Text("💡 **Long-Tap:** Name, Portionen und Nährwerte eines Lebensmittels schnell bearbeiten!")
                
                Divider()
                
                // Lebensmittel suchen
                Text("🔍 **Lebensmittel suchen**")
                    .font(.headline)
                Text("Nutze die **Suchleiste**, um schnell nach gespeicherten Lebensmitteln oder importierten Produkten zu suchen.")
                
                Divider()
                
                // Einträge löschen
                Text("🗑 **Einträge löschen**")
                    .font(.headline)
                Text("Wische einen Eintrag **nach links**, um ihn aus deiner Liste zu entfernen.")
                
                Divider()
                
                // Tag im Kalender auswählen
                Text("📅 **Tag im Kalender auswählen**")
                    .font(.headline)
                Text("Oben im Bildschirm kannst du den **Kalender** nutzen, um zwischen verschiedenen Tagen zu wechseln und deine Einträge anzusehen oder zu bearbeiten.")
                
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
        .navigationTitle("Hilfe")
    }
}

#Preview {
    HelpView()
}
