//
//  BarCodeView.swift
//  QuickCal
//
//  Created by Lukas Esch on 25.10.24.
//

import SwiftUI

struct BarCodeView: View {
    @AppStorage("onboarding") private var onboardingDone = false
    
    var body: some View {
        VStack {
            Text("Scanning product barcode will be added here")
                                Button(action: {
                                    onboardingDone = false
                                }) {
                                    Text("Reset Profile")
                                        .padding()
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
        }
        
        
    }
}

#Preview {
    BarCodeView()
}
