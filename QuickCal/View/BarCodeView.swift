//
//  BarCodeView.swift
//  QuickCal
//
//  Created by Lukas Esch on 25.10.24.
//

import SwiftUI

struct BarCodeView: View {
    
    var body: some View {
        VStack {
            HStack {
                Text("QuickCal")
                    .font(.title)
                    .fontWeight(.heavy)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 5.0)
                    .padding(.bottom, -2.0)
            }
            .padding(.horizontal, 25.0)
            .padding(.top, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            Text("Scanning product barcode will be added here")
            Spacer()
        }
        
        
    }
}

#Preview {
    BarCodeView()
}
