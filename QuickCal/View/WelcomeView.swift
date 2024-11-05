//
//  WelcomeView.swift
//  QuickCal
//
//  Created by Lukas Esch on 09.10.24.
//

import SwiftUI

struct WelcomeView: View {
    
    @State private var navigateToProfileView = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text("Willkommen bei")
                    .font(.subheadline)
                Text("QuickCal")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .multilineTextAlignment(.center)
            
                Button(action: {
                    navigateToProfileView = true // Navigation nach dem Aufruf der Funktion
                }) {
                    Text("Los gehts!")
                        .fontWeight(.bold)
                        .padding()
                        .foregroundColor(.white)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                Spacer()
            }
            .padding()
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $navigateToProfileView) {
                ProfileView() // Destination-Vew
            }
        }
    }
}

#Preview {
    WelcomeView()
}
