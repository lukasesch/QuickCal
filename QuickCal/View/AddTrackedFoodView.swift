//
//  AddTrackedFoodView.swift
//  QuickCal
//
//  Created by Lukas Esch on 05.11.24.
//

import SwiftUI
import CoreData

struct AddTrackedFoodView: View {
    @Binding var showAddTrackedFoodPanel: Bool
    @EnvironmentObject var viewModel: AddTrackedFoodViewModel
    
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
                ForEach(viewModel.foodItems) { food in
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
        .onAppear {
            viewModel.fetchFoodItems()
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    AddTrackedFoodView(showAddTrackedFoodPanel: .constant(false))
        .environment(\.managedObjectContext, context)
}
