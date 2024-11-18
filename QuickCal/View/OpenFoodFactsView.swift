//
//  OpenFoodFactsView.swift
//  QuickCal
//
//  Created by Lukas Esch on 17.11.24.
//

import SwiftUI

struct OpenFoodFactsView: View {
    @EnvironmentObject var openFoodFactsViewModel: OpenFoodFactsViewModel
    @State var textfield: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .leading) {
                    List {
                        Section(header: Text("OpenFoodFacts").font(.subheadline)) {
                            ForEach(openFoodFactsViewModel.products) { food in
                                HStack {
                                    Text("\(food.name), \(food.defaultQuantity, specifier: "%.0f") \(food.unit)")
                                    Spacer()
                                    Text("\(food.kcal) kcal")
                                }
                                .contentShape(Rectangle())
//                                .onTapGesture {
//                                    selectedFood = food
//                                    showCustomAlert = true // Trigger the custom alert
//                                }
                            }
                        }
                        
                    }
                    .searchable(text: $textfield, placement: .navigationBarDrawer(displayMode: .always))
                    .onSubmit(of: .search) {
                        openFoodFactsViewModel.search(text: textfield)
                    }
                    
                    .listStyle(.grouped)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 5)
                    .textCase(.none)
                    .padding()
                }
            }
        }
    }
}

#Preview {
    OpenFoodFactsView()
        .environmentObject(OpenFoodFactsViewModel()) // Ensure the EnvironmentObject is provided
}
