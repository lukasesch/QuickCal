//
//  MainView.swift
//  QuickCal
//
//  Created by Lukas Esch on 09.10.24.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        Text("Dein täglicher Kalorienbedarf beträgt")
        Text("0000 kcal")
            .font(.title2)
            .bold()
            .navigationBarBackButtonHidden(true)
    }
    
}

#Preview {
    MainView()
}
