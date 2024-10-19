//
//  ProfileView.swift
//  QuickCal
//
//  Created by Lukas Esch on 09.10.24.
//

import SwiftUI
import CoreData

struct ProfileView: View {
    // CoreData
    @Environment(\.managedObjectContext) private var viewContext
    // Connect View mit ViewModel
    @StateObject private var profileviewModel = ProfileViewModel()
    // Navigation to next View
    @State private var navigateToMainView = false
    
    //Focus State for Decimal Pad not disappearing
    @FocusState private var isKeyboardActive: Bool

    // States
    @State private var gender: String = "weiblich"
    @State private var nameTF: String = ""
    @State private var ageTF: String = ""
    @State private var weightTF: String = ""
    @State private var heightTF: String = ""
    @State private var bodyFatTF: String = ""
    @State private var activityLevel: String = "etwas"
    @State private var goal: String = "halten"

    //Body
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
                    TextField("Max", text: $nameTF)
                        .font(.headline)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.trailing)
                        .submitLabel(.done)
                        .focused($isKeyboardActive)
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
                        .focused($isKeyboardActive)
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
                        .focused($isKeyboardActive)
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
                        .focused($isKeyboardActive)
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
                        .focused($isKeyboardActive)
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
                    let bodyFatValue = bodyFatTF.isEmpty ? nil : bodyFatTF
                    profileviewModel.updateUser(context: viewContext, gender: gender, name: nameTF, age: ageTF, weight: weightTF, height: heightTF, bodyFat: bodyFatValue, activityLevel: activityLevel, goal: goal)
                    navigateToMainView = true
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
            .onTapGesture {
                isKeyboardActive = false
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $navigateToMainView) {
                MainView() // Ziel-View, die nach Navigation angezeigt wird
                    .environmentObject(profileviewModel)
            
            }
        }
    }
}


#Preview {
    ProfileView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
