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
    @AppStorage("onboarding") private var onboardingDone = false


    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Dein täglicher Kalorienbedarf beträgt")
                Text("\(mainViewModel.dailyCalories, specifier: "%.0f") kcal")
                    .font(.title2)
                    .bold()
                
                Button(action: {
                    onboardingDone = false
                }) {
                    Text("Reset")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                //if-case for testing, as MainView doesnt contain user from onboarding
                if onboardingDone == true {
                    mainViewModel.fetchUser(context: viewContext)
                }
            }

        }
    }
    
}

#Preview {
    MainView()
}
