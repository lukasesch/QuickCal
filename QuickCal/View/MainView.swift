//
//  MainView.swift
//  QuickCal
//
//  Created by Lukas Esch on 09.10.24.
//

import SwiftUI

struct MainView: View {
    
    @StateObject private var viewModel = MainViewModel()
    @EnvironmentObject var profileViewModel: ProfileViewModel


    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Dein täglicher Kalorienbedarf beträgt")
                Text("\(viewModel.dailyCalories, specifier: "%.0f") kcal")
                    .font(.title2)
                    .bold()
                    
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                viewModel.calculateCalories(for: profileViewModel.user) // Benutzer vom ProfileViewModel nutzen
            }

        }
    }
    
}

#Preview {
    MainView()
}
