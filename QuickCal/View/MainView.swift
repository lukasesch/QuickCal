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
                        .font(.title)
                        .fontWeight(.heavy)
                        .multilineTextAlignment(.center)
                        .padding()
                    Divider()
                    Spacer()
                    Spacer()
                    
                    HStack {
                        Spacer()
                        CircularProgressView(barColor: .blue, barWidth: 21, progressPercentage: kcalProgressPercentage)
                            .frame(width: 80, height: 100)
                        Spacer()
                        VStack {
                            Text("Kalorien: 0 / \(mainViewModel.dailyCalories, specifier: "%.0f") kcal")
                                .font(.callout)
                                .multilineTextAlignment(.trailing)
                            Text("Kohlenhydrate: 0 / \((mainViewModel.dailyCalories * 0.45 / 4), specifier: "%.0f") g")
                                .font(.callout)
                                .multilineTextAlignment(.trailing)
                            Text("Proteine: 0 / \((mainViewModel.dailyCalories * 0.40 / 4), specifier: "%.0f") g")
                                .font(.callout)
                                .multilineTextAlignment(.trailing)
                            Text("Fette: 0 / \((mainViewModel.dailyCalories * 0.15 / 9), specifier: "%.0f") g")
                                .font(.callout)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        Spacer()
                    }
        
                    Spacer()
                    Spacer()
                    Spacer()
                    HStack {
                        Spacer()
                        CircularProgressView(barColor: .green, barWidth: 12, progressPercentage: carbohydrateProgressPercentage)
                            .frame(width: 50, height: 50)
                        Spacer()
                        CircularProgressView(barColor: .orange, barWidth: 12, progressPercentage: proteinProgressPercentage)
                            .frame(width: 50, height: 50)
                        Spacer()
                        CircularProgressView(barColor: .purple, barWidth: 12, progressPercentage: fatProgressPercentage)
                            .frame(width: 50, height: 50)
                        Spacer()
                    }
                    Spacer()
                    Spacer()
                    Spacer()
                    Divider()
                    
                    
                    
                    List {
                        Section {
                            Text("Bauernbrot")
                            Text("Butter")
                            Text("Nutella")
                        } header: {
                            Text("Frühstück")
                        }
                        Section {
                            Text("Spaghetti")
                            Text("Pesto")
                        } header: {
                            Text("Mittagessen")
                        }
                        Section {
                            Text("Kartoffeln")
                            Text("Brokkoli")
                            Text("Rinderroulade")
                        } header: {
                            Text("Abendessen")
                        }
                        Section {
                            Text("Kartoffelchips")
                        } header: {
                            Text("Snacks")
                        }
                        
                    }
                    .listStyle(.inset)
//                    .clipShape(RoundedRectangle(cornerRadius: 10))
//                    .padding()
                    
                    
                    Spacer()
                    Spacer()
                    Spacer()
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
                if (barWidth > 20) {
                    Text("""
                     \(Int(progressPercentage * 100))%
                     """)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                } else {
                    Text("""
                     \(Int(progressPercentage * 100))%
                     """)
                    .font(.footnote)
                    .fontWeight(.regular)
                    .multilineTextAlignment(.center)
                }
        
            }
        }
    }
}

#Preview {
    MainView()
}
