//
//  ContentView.swift
//  QuickCal
//
//  Created by Lukas Esch on 09.10.24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @State private var gender: String = "weiblich"
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var bodyFat: String = ""
    @State private var sportFrequency: String = "Kein Sport"
    @State private var activityLevel: String = "kaum"
    @State private var goal: String = "halten"

    var body: some View {
        VStack(spacing: 20) {
            
            Spacer()
            Text("Dein Profil:")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            HStack {
                Button(action: { gender = "weiblich" }) {
                    Text("♀ Weiblich")
                        .frame(maxWidth: .infinity, maxHeight: 80)
                    }
                    .buttonStyle(.bordered)
                    .tint(gender == "weiblich" ? .blue : .gray)
                Button(action: { gender = "männlich" }) {
                    Text("♂ Männlich")
                        .frame(maxWidth: .infinity, maxHeight: 80)
                }
                    .buttonStyle(.bordered)
                    .tint(gender == "männlich" ? .blue : .gray)
            }
            
            Divider()
                    
            HStack {
                Text("Name:")
                    .font(.headline)
                    .foregroundColor(.gray)
                Spacer() // Füllt den verfügbaren Platz zwischen den Texten
                TextField("Max", text: $name)
                    .font(.headline)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.trailing)
            }
            HStack {
                Text("Alter:")
                    .font(.headline)
                    .foregroundColor(.gray)
                Spacer() // Füllt den verfügbaren Platz zwischen den Texten
                TextField("20", text: $age)
                    .font(.headline)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
            }
            HStack {
                Text("Gewicht:")
                    .font(.headline)
                    .foregroundColor(.gray)
                Spacer() // Füllt den verfügbaren Platz zwischen den Texten
                TextField("70", text: $weight)
                    .font(.headline)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
            }
            HStack {
                Text("Körpergröße:")
                    .font(.headline)
                    .foregroundColor(.gray)
                Spacer() // Füllt den verfügbaren Platz zwischen den Texten
                TextField("175", text: $height)
                    .font(.headline)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
            }
            HStack {
                Text("Körperfettanteil:")
                    .font(.headline)
                    .foregroundColor(.gray)
                Spacer() // Füllt den verfügbaren Platz zwischen den Texten
                TextField("20%", text: $bodyFat)
                    .font(.headline)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
            }
            
            Divider()

            HStack {
                Text("Sport pro Woche:")
                    .font(.headline)
                    .foregroundColor(.gray)
                Picker("Sport pro Woche", selection: $sportFrequency) {
                    Text("Kein Sport").tag("Kein Sport")
                    Text("1-2 Mal").tag("1-2 Mal")
                    Text("3-5 Mal").tag("3-5 Mal")
                }
                    .pickerStyle(MenuPickerStyle())
                Text("Aktivität:")
                    .font(.headline)
                    .foregroundColor(.gray)
                Picker("Alltagsaktivität", selection: $activityLevel) {
                    Text("Kaum").tag("kaum")
                    Text("Mäßig").tag("maessig")
                    Text("Sehr").tag("sehr")
                }
                    .pickerStyle(MenuPickerStyle())
                }
            
            Divider()
            
            HStack {
                Button(action: { goal = "abnehmen" }) {
                    Text("Abnehmen")
                        .frame(maxWidth: .infinity, maxHeight: 60)
                }
                .buttonStyle(.bordered)
                .tint(goal == "abnehmen" ? .blue : .gray)
                Button(action: { goal = "halten" }) {
                    Text("Gewicht halten")
                        .frame(maxWidth: .infinity, maxHeight: 60)
                }
                .buttonStyle(.bordered)
                .tint(goal == "halten" ? .blue : .gray)
                Button(action: { goal = "zunehmen" }) {
                    Text("Zunehmen")
                        .frame(maxWidth: .infinity, maxHeight: 60)
                }
                .buttonStyle(.bordered)
                .tint(goal == "zunehmen" ? .blue : .gray)
            }
            
            Spacer()

            Button(action: {
                // Aufruf der calculate-Funktion
            }) {
                Text("Weiter")
                    .frame(maxWidth: .infinity)
                    .fontWeight(.bold)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            
        }
        .padding()
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
