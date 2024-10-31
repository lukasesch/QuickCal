//
//  AddItemView.swift
//  QuickCal
//
//  Created by Lukas Esch on 25.10.24.
//

import SwiftUI

struct AddItemView: View {
    var body: some View {
        VStack {
            HStack {
                Text("QuickCal")
                    .font(.title)
                    .fontWeight(.heavy)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 5.0)
                    .padding(.bottom, -2.0)
            }
            .padding(.horizontal, 25.0)
            .frame(maxWidth: .infinity, alignment: .leading)
            VStack {
                Button(action: {}) {
                    Text("Hinzufügen")
                        .font(.title2)
                        .frame(maxWidth: .infinity, maxHeight: 80)
                        .fontWeight(.bold)
                        .padding()
                        .foregroundColor(.white)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                HStack {
                    Button(action: {}) {
                        Text("Lebensmittel erstellen")
                            .frame(maxWidth: .infinity, maxHeight: 40)
                            .fontWeight(.semibold)
                            .padding()
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    Button(action: {}) {
                        Text("Gericht erstellen")
                            .frame(maxWidth: .infinity, maxHeight: 40)
                            .fontWeight(.semibold)
                            .padding()
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
                Text("Zuletzt hinzugefügt:")
            }
            .padding()
            
        }
        Spacer()
    }
}

#Preview {
    AddItemView()
}
