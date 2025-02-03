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
    // UPDATE @Environment(\.managedObjectContext) private var viewContext
    // Connect View mit ViewModel
    @EnvironmentObject private var profileviewModel: ProfileViewModel
    @FocusState private var focusedField: Field?
    @AppStorage("onboarding") private var onboardingDone = false
    
    @State private var gender: String = "weiblich"
    @State private var nameTF: String = ""
    @State private var ageTF: String = ""
    @State private var weightTF: String = ""
    @State private var heightTF: String = ""
    @State private var bodyFatTF: String = ""
    @State private var activityLevel: String = "etwas"
    @State private var goal: String = "halten"

    enum Field: Int, CaseIterable {
        case name, age, weight, height, bodyFat
    }

    //Body
    var body: some View {
        NavigationStack{
            VStack(spacing: 20) {
                
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
                        .focused($focusedField, equals: .name)
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
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .age)
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
                        .focused($focusedField, equals: .weight)
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
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .height)
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
                        .focused($focusedField, equals: .bodyFat)
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
                    if profileviewModel.validateInput(name: nameTF, age: ageTF, weight: weightTF, height: heightTF) {
                        let bodyFatValue = bodyFatTF.isEmpty ? nil : bodyFatTF
                        profileviewModel.updateUser(gender: gender, name: nameTF, age: ageTF, weight: weightTF, height: heightTF, bodyFat: bodyFatValue, activityLevel: activityLevel, goal: goal)
                        onboardingDone = true
                    } else {
                        // Inputs incorrect
                        print("Eingaben sind ungültig")
                    }
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
                focusedField = nil
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button(action: { moveFocus(-1) }) {
                        Image(systemName: "chevron.up")
                    }
                    .disabled(focusedField == .name)
                    
                    Button(action: { moveFocus(1) }) {
                        Image(systemName: "chevron.down")
                    }
                    .disabled(focusedField == .bodyFat)
                    
                    Spacer()
                    
                    Button("Fertig") {
                        focusedField = nil
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $profileviewModel.navigateToMainView) {
                MainView() // Ziel-View, die nach Navigation angezeigt wird
                    .environmentObject(profileviewModel)
            
            }
            .alert(item: $profileviewModel.errorMessage) { errorMessage in
                Alert(title: Text("Fehler"), message: Text(errorMessage.message), dismissButton: .default(Text("OK")))
            }
            .navigationTitle("Dein Profil")
        }
    }
    
    // Function to move focus between fields
    private func moveFocus(_ direction: Int) {
        guard let current = focusedField,
              let newIndex = Field.allCases.firstIndex(of: current)?.advanced(by: direction),
              Field.allCases.indices.contains(newIndex) else {
            return
        }
        focusedField = Field.allCases[newIndex]
    }
}


#Preview {
    let context = PersistenceController.preview.container.viewContext
    ProfileView()
        .environment(\.managedObjectContext, context)
        .environmentObject(ProfileViewModel(context: context))
}
