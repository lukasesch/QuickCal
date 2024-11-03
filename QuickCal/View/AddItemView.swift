//
//  AddItemView.swift
//  QuickCal
//
//  Created by Lukas Esch on 25.10.24.
//

import SwiftUI
import CoreData

struct AddItemView: View {
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    @FetchRequest(entity: Food.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Food.name, ascending: true)]
    ) var foodItems: FetchedResults<Food>
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
                        CreatePanelView(showCreatePanel: $showCreatePanel)
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
                List(foodItems) { food in
                    HStack {
                        Text(food.name ?? "Unbekannt")
                        Spacer()
                        Text("\(food.kcal) kcal")
                        Spacer()
                        Text(" | ")
                        Spacer()
                        Text("C: \(String(format: "%.1f", food.carbohydrate))")
                        Spacer()
                        Text("P: \(String(format: "%.1f", food.protein))")
                        Spacer()
                        Text("F: \(String(format: "%.1f", food.fat))")
                    }
                }
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
