//
//  MainView.swift
//  QuickCal
//
//  Created by Lukas Esch on 09.10.24.
//

import SwiftUI

struct MainView: View {
    
    @StateObject private var mainViewModel = MainViewModel()
    @Environment(\.managedObjectContext) private var viewContext


    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Dein täglicher Kalorienbedarf beträgt")
                Text("\(mainViewModel.dailyCalories, specifier: "%.0f") kcal")
                    .font(.title2)
                    .bold()
                    
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                mainViewModel.fetchUser(context: viewContext)
            }

        }
    }
    
}

#Preview {
    MainView()
}
