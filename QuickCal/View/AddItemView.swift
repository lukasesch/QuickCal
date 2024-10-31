//
//  AddItemView.swift
//  QuickCal
//
//  Created by Lukas Esch on 25.10.24.
//

import SwiftUI

struct AddItemView: View {
    
    @State private var showCreatePanel = false
    
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
                Button(action: {
                    
                }) {
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
                    Button(action: {
                        showCreatePanel.toggle()
                    }) {
                        Text("Lebensmittel erstellen")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, maxHeight: 40)
                            .fontWeight(.semibold)
                            .padding()
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .sheet(isPresented: $showCreatePanel) {
                        CreatePanelView()
                    }
                    Button(action: {}) {
                        Text("""
                            Gericht 
                            erstellen
                            """)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, maxHeight: 40)
                            .fontWeight(.semibold)
                            .padding()
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
                Spacer()
                Text("Zuletzt hinzugefügt:")
                Spacer()
            }
            .padding()
            
        }
        //Spacer()
    }
}

#Preview {
    AddItemView()
}
