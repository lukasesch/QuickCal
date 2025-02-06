//
//  CalorieMacroView.swift
//  QuickCal
//
//  Created by Lukas Esch on 06.02.25.
//

import SwiftUI

struct CalorieMacroView: View {
    @EnvironmentObject var calorieMacroViewModel: CalorieMacroViewModel
    @EnvironmentObject var mainViewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            Stepper(value: $calorieMacroViewModel.calories, in: 1000...5000, step: 50) {
                Text("Kalorien: **\(Int(calorieMacroViewModel.calories))** kcal")
                    .font(.title3)
            }
            
            Divider()

            Group {
                // Kohlenhydrate
                VStack(alignment: .leading) {
                    Text("Kohlenhydrate: **\(Int(calorieMacroViewModel.carbsPercentage))%** (\(calorieMacroViewModel.carbsGrams)g)")
                    Slider(value: $calorieMacroViewModel.carbsPercentage, in: 0...100, step: 1)
                }
                
                // Proteine
                VStack(alignment: .leading) {
                    Text("Proteine: **\(Int(calorieMacroViewModel.proteinsPercentage))%** (\(calorieMacroViewModel.proteinsGrams)g)")
                    Slider(value: $calorieMacroViewModel.proteinsPercentage, in: 0...100, step: 1)
                }
                
                // Fette
                VStack(alignment: .leading) {
                    Text("Fette: **\(Int(calorieMacroViewModel.fatsPercentage))%** (\(calorieMacroViewModel.fatsGrams)g)")
                    Slider(value: $calorieMacroViewModel.fatsPercentage, in: 0...100, step: 1)
                }
            }
            
            // Gesamtsumme der Makronährstoff-Prozente anzeigen
            Text("Gesamt: **\(Int(calorieMacroViewModel.carbsPercentage + calorieMacroViewModel.proteinsPercentage + calorieMacroViewModel.fatsPercentage))%**")
                .foregroundColor(
                    calorieMacroViewModel.carbsPercentage + calorieMacroViewModel.proteinsPercentage + calorieMacroViewModel.fatsPercentage == 100
                    ? .gray
                    : .red
                )
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.vertical, 5)

            Divider()
            
            Button(action: {
                calorieMacroViewModel.saveCalorieData()
                mainViewModel.checkAndCalculateDailyCalories()
                dismiss()
            }) {
                Text("Speichern")
                    .frame(maxWidth: .infinity)
                    .fontWeight(.bold)
                    .padding()
                    .foregroundColor(.white)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            
            Spacer()
        }
        .onAppear {
            calorieMacroViewModel.fetchLatestKcalEntry()
        }
        .padding()
        .navigationTitle("Kalorien & Makronährstoffe")
    }
}


#Preview {
    let context = PersistenceController.preview.container.viewContext
    CalorieMacroView()
        .environment(\.managedObjectContext, context)
        .environmentObject(CalorieMacroViewModel(context: context))
        .environmentObject(MainViewModel(context: context))
    
}
