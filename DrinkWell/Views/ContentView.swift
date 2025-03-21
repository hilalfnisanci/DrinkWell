//
//  ContentView.swift
//  DrinkWell
//
//  Created by Hilal on 18.03.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var viewModel = WaterViewModel()
    @Binding var selectedTab: Int
    @State private var showingAddSheet = false
    @State private var showingNotificationAddSheet = false
    @StateObject private var preferences = UserPreferences.shared

    var body: some View {
        TabView(selection: $selectedTab) {
            // MAIN SCREEN
            NavigationStack {
                VStack(spacing: 20) {
                    // Progress indicator
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 15)
                            .opacity(0.3)
                            .foregroundColor(.blue)
                        
                        Circle()
                            .trim(from: 0.0, to: CGFloat(viewModel.progress))
                            .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round))
                            .foregroundColor(.blue)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut, value: viewModel.progress)
                        
                        VStack {
                            // Unit display based on Metric/Imperial system
                            Text(preferences.useMetricSystem ? 
                                "\(Int(viewModel.todaysTotal)) ml" :
                                String(format: "%.1f oz", viewModel.todaysTotal * 0.033814))
                                .font(.system(size: 32, weight: .bold))
                            
                            Text(preferences.useMetricSystem ?
                                String(format: "target_label".localized + " %d ml", Int(viewModel.dailyGoal)) :
                                String(format: "target_label".localized + " %.1f oz", viewModel.dailyGoal * 0.033814))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("\(Int(viewModel.progress * 100))%")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                    }
                    .frame(height: 200)
                    .padding()
                    
                    // Info panel
                    HStack(spacing: 20) {
                        InfoCard(
                            title: "drunk_label".localized,
                            value: preferences.useMetricSystem ?
                                "\(Int(viewModel.todaysTotal)) ml" :
                                String(format: "%.1f oz", viewModel.todaysTotal * 0.033814),
                            systemImage: "drop.fill",
                            color: .blue
                        )
                        
                        InfoCard(
                            title: "remaining_label".localized,
                            value: preferences.useMetricSystem ?
                                "\(Int(max(0, viewModel.dailyGoal - viewModel.todaysTotal))) ml" :
                                String(format: "%.1f oz", max(0, viewModel.dailyGoal - viewModel.todaysTotal) * 0.033814),
                            systemImage: "gauge",
                            color: .orange
                        )
                    }
                    .padding(.horizontal)
                    
                    // Add water button
                    Button(action: {
                        showingAddSheet = true
                    }) {
                        Label("add_water_button".localized, systemImage: "plus.circle.fill")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .accessibilityIdentifier("add_water_button")
                    .padding(.horizontal)
                    
                    // Daily records list
                    List {
                        Section(header: Text("today_records".localized)) {
                            ForEach(viewModel.waterIntakes.filter { 
                                Calendar.current.isDateInToday($0.timestamp)
                            }) { intake in
                                WaterIntakeRow(intake: intake)
                            }
                            .onDelete { indexSet in
                                Task {
                                    await viewModel.removeWaterIntake(at: indexSet)
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
                .navigationTitle("app_name".localized)
                .sheet(isPresented: $showingAddSheet) {
                    AddWaterView(isPresented: $showingAddSheet) { amount, note in
                        Task {
                            let finalAmount = preferences.useMetricSystem ? 
                                amount : 
                                amount * 29.5735
                            await viewModel.addWaterIntake(amount: finalAmount, note: note)
                        }
                    }
                }.sheet(isPresented: $showingNotificationAddSheet) {
                    AddWaterView(isPresented: $showingNotificationAddSheet) { amount, note in
                        Task {
                            let finalAmount = preferences.useMetricSystem ? 
                                amount : 
                                amount * 29.5735
                            await viewModel.addWaterIntake(amount: finalAmount, note: note)
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("OpenAddWaterView"))) { _ in
                    showingNotificationAddSheet = true
                }
                .onAppear {
                    // Load current data when the view appears
                    Task {
                        await viewModel.loadWaterIntakes()
                    }
                }
            }
            .tabItem {
                Label("home_tab".localized, systemImage: "house.fill")
            }
            .tag(0)
            
            // STATISTICS PAGE
            StatsView()
                .tabItem {
                    Label("stats_tab".localized, systemImage: "chart.bar.fill")
                }
                .tag(1)
            
            // SETTINGS PAGE
            SettingsView(selectedTab: $selectedTab)
                .tabItem {
                    Label("settings_tab".localized, systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .onAppear {
            // Set TabBar appearance to appropriate color
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            UITabBar.appearance().scrollEdgeAppearance = appearance
            UITabBar.appearance().standardAppearance = appearance
        }
        .preferredColorScheme(preferences.isDarkMode ? .dark : .light)
        .environmentObject(preferences)
        .environmentObject(viewModel)
    }
    
}

// Info card component
struct InfoCard: View {
    var title: String
    var value: String
    var systemImage: String
    var color: Color
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            HStack {
                Text(value)
                    .font(.headline)
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

// Water intake row
struct WaterIntakeRow: View {
    var intake: WaterIntake
    @EnvironmentObject private var preferences: UserPreferences
    
    var body: some View {
        HStack {
            Image(systemName: "drop.fill")
                .foregroundColor(.blue)
                .imageScale(.large)
            
            VStack(alignment: .leading) {
                Text(preferences.useMetricSystem ?
                    "\(Int(intake.amount)) ml" :
                    String(format: "%.1f oz", intake.amount * 0.033814))
                    .font(.headline)
                
                Text(intake.timestamp, style: .time)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let note = intake.note, !note.isEmpty {
                Text(note)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView(selectedTab: .constant(0))
        .environmentObject(UserPreferences.shared)
        .environmentObject(WaterViewModel())
}
