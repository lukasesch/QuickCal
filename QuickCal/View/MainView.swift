//
//  MainView.swift
//  QuickCal
//
//  Created by Lukas Esch on 09.10.24.
//

import SwiftUI

struct MainView: View {
    
    @EnvironmentObject var mainViewModel: MainViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("onboarding") private var onboardingDone = false
    @State private var currentPage = 1
    @State private var showingSettings = false
    
    // Percentage is calculated 'on the fly'
    var kcalProgressPercentage: Double {
        guard mainViewModel.kcalGoal > 0 else { return 0 }
        return 1.0 - ((mainViewModel.kcalGoal - mainViewModel.kcalReached) / mainViewModel.kcalGoal)
    }
    var carbsProgressPercentage: Double {
        guard mainViewModel.carbsGoal > 0 else { return 0 }
        return 1.0 - ((Double(mainViewModel.carbsGoal) - Double(mainViewModel.carbsReached)) / Double(mainViewModel.carbsGoal))
    }
    var proteinProgressPercentage: Double {
        guard mainViewModel.proteinGoal > 0 else { return 0 }
        return 1.0 - ((Double(mainViewModel.proteinGoal) - Double(mainViewModel.proteinReached)) / Double(mainViewModel.proteinGoal))
    }
    var fatProgressPercentage: Double {
        guard mainViewModel.fatGoal > 0 else { return 0 }
        return 1.0 - ((Double(mainViewModel.fatGoal) - Double(mainViewModel.fatReached)) / Double(mainViewModel.fatGoal))
    }


    
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
                        Spacer()
                        
                        Button(action: {
                            showingSettings.toggle()
                        }) {
                            Image(systemName: "gearshape")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                        .sheet(isPresented: $showingSettings) {
                            SettingsView()
                        }
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
                        MacroBars(barColor: .green, barWidth: 90, barHeight: 12, goal: mainViewModel.carbsGoal, progressPercentage: carbsProgressPercentage, barName: "Kohlenhydrate")
                        Spacer()
                        MacroBars(barColor: .orange, barWidth: 90, barHeight: 12, goal: mainViewModel.proteinGoal, progressPercentage: proteinProgressPercentage, barName: "Protein")
                        Spacer()
                        MacroBars(barColor: .purple, barWidth: 90, barHeight: 12, goal: mainViewModel.fatGoal, progressPercentage: fatProgressPercentage, barName: "Fett")
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
                    //Preview debugging as no user exists here
                    if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                        mainViewModel.kcalGoal = 2000
                        mainViewModel.kcalReached = 0
                        mainViewModel.carbsGoal = 200
                        mainViewModel.proteinGoal = 100
                        mainViewModel.fatGoal = 70
                    } else {
                        mainViewModel.checkAndCalculateDailyCalories(context: viewContext)
                        print("MainView: checkAndCalculateDailyCalories run!")
                    }
                    
                }
                //.tabItem { Text("Main View") }
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
        @EnvironmentObject var mainViewModel: MainViewModel
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
                    .rotationEffect(Angle(degrees: 157))
                Circle()
                    .trim(from: 0, to: 0.63 * progressPercentage)
                    .stroke(
                        barColor,
                        style: StrokeStyle(lineWidth: barWidth, lineCap: .round))
                    .rotationEffect(Angle(degrees: 157))
                
                VStack {
                    Text("""
                        \(String(format: "%.0f", mainViewModel.kcalReached))
                        """)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    
                    Text("""
                        von
                         \(String(format: "%.0f", mainViewModel.kcalGoal)) kcal
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
        var goal: Int
        var progressPercentage: Double
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
                Text("\(String(format: "%.0f", (Double(goal) * progressPercentage))) / \(goal) g")
                    .font(.footnote)
                    .fontWeight(.regular)
                    .multilineTextAlignment(.center)
                
            }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(MainViewModel())
}
