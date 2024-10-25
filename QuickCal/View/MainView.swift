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
    @State private var currentPage = 1
    @State private var kcalProgressPercentage = 0.45
    @State private var carbohydrateProgressPercentage = 0.18
    @State private var proteinProgressPercentage = 0.37
    @State private var fatProgressPercentage = 0.11


    
    var body: some View {
        NavigationStack {
            TabView(selection: $currentPage) {
                
                // BarCode View
                BarCodeView()
                    .tabItem { Text("Barcode") } // TabItem für BarCodeView
                    .tag(0)
                
                
                VStack {
                    Text("QuickCal")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .multilineTextAlignment(.center)
                    Divider()
                    Spacer()
                    CircularProgressView(barColor: .blue, barWidth: 25, progressPercentage: kcalProgressPercentage)
                        .frame(width: 120, height: 120)
                    Spacer()
                    HStack {
                        Spacer()
                        CircularProgressView(barColor: .green, barWidth: 15, progressPercentage: carbohydrateProgressPercentage)
                            .frame(width: 80, height: 80)
                        Spacer()
                        CircularProgressView(barColor: .orange, barWidth: 15, progressPercentage: proteinProgressPercentage)
                            .frame(width: 80, height: 80)
                        Spacer()
                        CircularProgressView(barColor: .purple, barWidth: 15, progressPercentage: fatProgressPercentage)
                            .frame(width: 80, height: 80)
                        Spacer()
                    }
                    Spacer()
                    Divider()
                    Spacer()
                    Spacer()
                    
                    Text("Dein täglicher Kalorienbedarf beträgt")
                    Text("\(mainViewModel.dailyCalories, specifier: "%.0f") kcal")
                        .font(.title2)
                        .bold()
                    
                    Button(action: {
                        onboardingDone = false
                    }) {
                        Text("Reset Profile")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    Spacer()
                }
                .navigationBarBackButtonHidden(true)
                .onAppear {
                    //if-case for testing, as MainView doesnt contain user from onboarding
                    if onboardingDone == true {
                        mainViewModel.fetchUser(context: viewContext)
                    }
                }
                .tabItem { Text("Main View") }
                .tag(1)
                
                
                
                // Add Item View
                AddItemView()
                    .tabItem { Text("Add Item") } // TabItem für AddItemView
                    .tag(2)
            }
            .tabViewStyle(.page)
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        }
    }
    
    struct CircularProgressView: View {
        var barColor: Color
        var barWidth: CGFloat
        var progressPercentage: CGFloat
        var body: some View {
            ZStack {
                Circle()
                    .stroke(
                        barColor.opacity(0.4),
                        lineWidth: barWidth
                    )

                Circle()
                    .trim(from: 0, to: progressPercentage)
                    .stroke(
                        barColor,
                        lineWidth: barWidth
                    )
                    .rotationEffect(Angle(degrees: -90))
                Text("""
                     \(progressPercentage, specifier: "%.2f")%
                     """)
                .fontWeight(barWidth > 20 ? .bold : .regular)
                
                .multilineTextAlignment(.center)
            }
        }
    }
}

#Preview {
    MainView()
}
