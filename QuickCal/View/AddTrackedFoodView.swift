//
//  AddTrackedFoodView.swift
//  QuickCal
//
//  Created by Lukas Esch on 05.11.24.
//

import SwiftUI

struct AddTrackedFoodView: View {
    @Binding var showAddTrackedFoodPanel: Bool
    
    //Database
    @Environment(\.managedObjectContext) private var managedObjectContext
    @FetchRequest(entity: Food.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Food.name, ascending: true)]
    ) var foodItems: FetchedResults<Food>
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Suchleiste")
                Spacer()
                Text("+")
            }
            Divider()
            Spacer()
            
            Text("Liste der letzten Lebensmittel")
                .font(.headline)
                .padding(.bottom, 5)
            
            List {
                ForEach(foodItems) { food in
                    HStack {
                        Text(food.name ?? "Unbekannt")
                        Spacer()
                        Text("\(food.kcal) kcal")
                    }
                }
            }
            .listStyle(.grouped)
            Spacer()
            Divider()
            Spacer()
            Text("Liste der letzten Gerichte")
                .font(.headline)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    AddTrackedFoodView(showAddTrackedFoodPanel: .constant(false))
}
