//
//  EditProfileView.swift
//  QuickCal
//
//  Created by Lukas Esch on 05.02.25.
//

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject private var editProfileViewModel: EditProfileViewModel
    @EnvironmentObject var mainViewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss
    
    @FocusState private var focusedField: Field?
    
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
    
    
    var body: some View {
        NavigationStack{
            ScrollView {
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
                        if editProfileViewModel.validateInput(name: nameTF, age: ageTF, weight: weightTF, height: heightTF) {
                            editProfileViewModel.updateUser(
                                gender: gender,
                                name: nameTF,
                                age: ageTF,
                                weight: weightTF,
                                height: heightTF,
                                bodyFat: bodyFatTF.isEmpty ? nil : bodyFatTF,
                                activityLevel: activityLevel,
                                goal: goal
                            )
                        }
                        mainViewModel.recalculateCalories()
                        dismiss()
                    }) {
                        Text("Aktualisieren")
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
                .onAppear {
                    loadProfileData()
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
                .alert(item: $editProfileViewModel.errorMessage) { errorMessage in
                    Alert(title: Text("Fehler"), message: Text(errorMessage.message), dismissButton: .default(Text("OK")))
                }
                .navigationTitle("Profil bearbeiten")
            }
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
    
    private func loadProfileData() {
        guard let user = editProfileViewModel.user else { return }
        gender = user.gender ?? "weiblich"
        nameTF = user.name ?? ""
        ageTF = String(user.age)
        weightTF = String(user.weight)
        heightTF = String(user.height)
        bodyFatTF = user.bodyfat == 0.0 ? "" : String(user.bodyfat)
        activityLevel = mapActivityLevel(user.activity)
        goal = mapGoal(user.goal)
    }
    
    private func mapActivityLevel(_ value: Float) -> String {
        switch value {
        case 1.3: return "wenig"
        case 1.5: return "etwas"
        case 1.7: return "aktiv"
        case 1.9: return "sehr aktiv"
        default: return "etwas"
        }
    }
    
    private func mapGoal(_ value: Int16) -> String {
        switch value {
        case 0: return "abnehmen"
        case 1: return "halten"
        case 2: return "zunehmen"
        default: return "halten" // Standardwert
        }
    }
}

#Preview {
    EditProfileView()
}
