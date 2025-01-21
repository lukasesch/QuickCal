//
//  CreatePanelView.swift
//  QuickCal
//
//  Created by Lukas Esch on 31.10.24.
//

import SwiftUI

struct CreateFoodPanelView: View {
    @State private var nameTF = ""
    @State private var defaultQuantityTF = ""
    @State private var unit = "g"
    @State private var caloriesTF = ""
    @State private var carbsTF = ""
    @State private var proteinTF = ""
    @State private var fatTF = ""
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var createPanelViewModel: CreateFoodPanelViewModel
        
    //NEW FocusState for tracking focused field
    @FocusState private var focusedField: Field?
    //NEW Enum for focus tracking
    enum Field: Int, CaseIterable {
        case name, defaultQuantity, kcal, carbs, protein, fat
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Neues Lebensmittel:")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
            Divider()
            HStack {
                Text("Name:")
                    .font(.headline)
                    .foregroundColor(.gray)
                Spacer() // Füllt den verfügbaren Platz zwischen den Texten
                TextField("z.B. Banane", text: $nameTF)
                    .font(.headline)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.trailing)
                    .submitLabel(.done)
                    .focused($focusedField, equals: .name)
                    .padding(.vertical, 5.0)
                    .padding(.trailing, 16.0)
            }
            Divider()
            HStack {
                Text("Portionsgröße:")
                    .font(.headline)
                    .foregroundColor(.gray)
                Spacer() // Füllt den verfügbaren Platz zwischen den Texten
                TextField("100", text: $defaultQuantityTF)
                    .keyboardType(.numberPad)
                    .font(.headline)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.trailing)
                    .submitLabel(.done)
                    .focused($focusedField, equals: .defaultQuantity)
                
                Picker("Einheit", selection: $unit) {
                    Text("Gramm").tag("g")
                    Text("Kilogramm").tag("kg")
                    Text("Milliliter").tag("ml")
                    Text("Liter").tag("l")
                    Text("Stück").tag("Stück")
                }
                .pickerStyle(MenuPickerStyle())
                
            }
            Divider()
            HStack {
                Text("Kalorien (kcal):")
                    .font(.headline)
                    .foregroundColor(.gray)
                Spacer() // Füllt den verfügbaren Platz zwischen den Texten
                TextField("83", text: $caloriesTF)
                    .keyboardType(.decimalPad)
                    .font(.headline)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.trailing)
                    .submitLabel(.done)
                    .focused($focusedField, equals: .kcal)
                    .padding(.vertical, 5.0)
                    .padding(.trailing, 16.0)
            }
            HStack {
                Text("Kohlenhydrate:")
                    .font(.headline)
                    .foregroundColor(.gray)
                Spacer() // Füllt den verfügbaren Platz zwischen den Texten
                TextField("43", text: $carbsTF)
                    .keyboardType(.decimalPad)
                    .font(.headline)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.trailing)
                    .submitLabel(.done)
                    .focused($focusedField, equals: .carbs)
                    .padding(.vertical, 5.0)
                    .padding(.trailing, 16.0)
            }
            HStack {
                Text("Protein:")
                    .font(.headline)
                    .foregroundColor(.gray)
                Spacer() // Füllt den verfügbaren Platz zwischen den Texten
                TextField("5.1", text: $proteinTF)
                    .keyboardType(.decimalPad)
                    .font(.headline)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.trailing)
                    .submitLabel(.done)
                    .focused($focusedField, equals: .protein)
                    .padding(.vertical, 5.0)
                    .padding(.trailing, 16.0)
            }
            HStack {
                Text("Fett:")
                    .font(.headline)
                    .foregroundColor(.gray)
                Spacer() // Füllt den verfügbaren Platz zwischen den Texten
                TextField("1.3", text: $fatTF)
                    .keyboardType(.decimalPad)
                    .font(.headline)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.trailing)
                    .submitLabel(.done)
                    .focused($focusedField, equals: .fat)
                    .padding(.vertical, 5.0)
                    .padding(.trailing, 16.0)
            }
            Spacer()
            HStack {
                Button(action: {
                    createPanelViewModel.createFood(name: nameTF, defaultQuantity: defaultQuantityTF, unit: unit, calories: caloriesTF, carbs: carbsTF, protein: proteinTF, fat: fatTF)
                    dismiss()
                    
                }) {
                    Text("Erstellen")
                        .frame(maxWidth: .infinity)
                        .fontWeight(.bold)
                        .padding()
                        .foregroundColor(.white)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                Button(action: {
                    dismiss()
                }) {
                    Text("Abbrechen")
                        .frame(maxWidth: .infinity)
                        .fontWeight(.bold)
                        .padding()
                        .foregroundColor(.white)
                }
                .buttonStyle(.bordered)
                .tint(.blue)
            }
            
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
                .disabled(focusedField == .fat)
                
                Spacer()
                
                Button("Fertig") {
                    focusedField = nil
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
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
    CreateFoodPanelView()
}
