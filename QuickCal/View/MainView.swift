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
    @State private var kcalProgressPercentage = 0.42
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
                    HStack {
                        Text("QuickCal")
                            .font(.title)
                            .fontWeight(.heavy)
                            .multilineTextAlignment(.leading)
                            .padding(.top, 5.0)
                            .padding(.bottom, -2.0)
                    }
                    .padding(.horizontal, 25.0)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    
                    HStack {
                        Spacer()
                        HalfCircularProgressView(barColor: .blue, barWidth: 20, progressPercentage: kcalProgressPercentage)
                            .frame(width: 200, height: 200)
                            
                        Spacer()
                    }
                    .padding(.bottom, -40)
                    HStack {
                        Spacer()
                        Spacer()
                        MacroBars(barColor: .green, barWidth: 90, barHeight: 15, progressPercentage: carbohydrateProgressPercentage, barName: "Kohlenhydrate")
                        Spacer()
                        MacroBars(barColor: .orange, barWidth: 90, barHeight: 15, progressPercentage: proteinProgressPercentage,
                                  barName: "Protein")
                        Spacer()
                        MacroBars(barColor: .purple, barWidth: 90, barHeight: 15, progressPercentage: fatProgressPercentage,
                                  barName: "Fett")
                        Spacer()
                        Spacer()
                    }
                    
                    Spacer()
                    Spacer()
    
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
//                    .listStyle(.inset)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding()
                    .shadow(radius: 10)
                    
                    
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
    
    struct HalfCircularProgressView: View {
        var barColor: Color
        var barWidth: CGFloat
        var progressPercentage: CGFloat
        var body: some View {
            ZStack {
                Circle()
                    .trim(from: 0, to: 0.63)
                    .stroke(
                        barColor.opacity(0.25),
                        style: StrokeStyle(lineWidth: barWidth, lineCap: .round))
                    .rotationEffect(Angle(degrees: 159))
                Circle()
                    .trim(from: 0, to: 0.63 * progressPercentage)
                    .stroke(
                        barColor,
                        style: StrokeStyle(lineWidth: barWidth, lineCap: .round))
                    .rotationEffect(Angle(degrees: 159))
                
                VStack {
                    Text("""
                        1241
                        """)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    
                    Text("""
                        kcal
                        """)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
                }
            }
        }
    }
    
    struct MacroBars: View {
        var barColor: Color
        var barWidth: CGFloat
        var barHeight: CGFloat
        var progressPercentage: CGFloat
        var barName: String
        var body: some View {
            VStack {
                Text("\(barName)")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                ZStack (alignment: .leading) {
                    Rectangle()
                        .frame(width: barWidth, height: barHeight)
                        .foregroundStyle(barColor)
                        .opacity(0.25)
                        .clipShape(.capsule)
                    Rectangle()
                        .frame(width: barWidth * progressPercentage, height: barHeight)
                        .foregroundStyle(barColor)
                        .clipShape(.capsule)
                }
                Text("81 / 131g")
                    .font(.footnote)
                    .fontWeight(.regular)
                    .multilineTextAlignment(.center)
                
            }
        }
    }
}

#Preview {
    MainView()
}
