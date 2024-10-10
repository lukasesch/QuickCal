//
//  ProfileView.swift
//  QuickCal
//
//  Created by Lukas Esch on 09.10.24.
//

import SwiftUI
import CoreData

struct ProfileView: View {
    @Environment(\.managedObjectContext) private var viewContext

//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
//        animation: .default)
//    private var items: FetchedResults<Item>
    
    @State private var navigateToMainView = false
    
    @State private var gender: String = "weiblich"
    @State private var name: String = ""
    @State private var ageTF: String = ""
    @State private var weightTF: String = ""
    @State private var heightTF: String = ""
    @State private var bodyFatTF: String = ""
    @State private var sportFrequency: String = "Kein Sport"
    @State private var activityLevel: String = "etwas"
    @State private var goal: String = "halten"

    var body: some View {
        NavigationStack{
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
                        .submitLabel(.done)
                }
                HStack {
                    Text("Alter:")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Spacer() // Füllt den verfügbaren Platz zwischen den Texten
                    TextField("20", text: $ageTF)
                        .font(.headline)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .submitLabel(.done)
                }
                HStack {
                    Text("Gewicht:")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Spacer() // Füllt den verfügbaren Platz zwischen den Texten
                    TextField("70", text: $weightTF)
                        .font(.headline)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .submitLabel(.done)
                }
                HStack {
                    Text("Körpergröße:")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Spacer() // Füllt den verfügbaren Platz zwischen den Texten
                    TextField("175", text: $heightTF)
                        .font(.headline)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .submitLabel(.done)
                }
                HStack {
                    Text("Körperfettanteil: (optional)")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Spacer() // Füllt den verfügbaren Platz zwischen den Texten
                    TextField("20%", text: $bodyFatTF)
                        .font(.headline)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .submitLabel(.done)
                }
                
                Divider()
                
                HStack {
                    Text("Aktivität:")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Picker("Alltagsaktivität", selection: $activityLevel) {
                        Text("Wenig aktiv").tag("wenig")
                        Text("Etwas").tag("etwas")
                        Text("Aktiv").tag("aktiv")
                        Text("Sehr aktiv").tag("sehr aktiv")
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
                    //calculate() // kcal Berechnen Funnktion
                    navigateToMainView = true // Navigation nach dem Aufruf der Funktion
                }) {
                    Text("Weiter")
                        .frame(maxWidth: .infinity)
                        .fontWeight(.bold)
                        .padding()
                        .foregroundColor(.white)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
        
            }
            .padding()
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $navigateToMainView) {
                MainView() // Ziel-View, die nach Navigation angezeigt wird
            }
        }
    }
}

#Preview {
    ProfileView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
