//
//  SettingsView.swift
//  DrinkWell
//
//  Created by Hilal on 18.03.2025.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    
    @StateObject private var preferences = UserPreferences.shared
    @EnvironmentObject private var viewModel: WaterViewModel 
    @StateObject private var notificationManager = NotificationManager.shared

    @State private var isEditingProfile = false
    @State private var showPermissionAlert = false
    @State private var showSettingsAlert = false
    @State var selectedLanguage: String = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
    @Binding var selectedTab: Int 

    // Unit conversions
    private var goalInOz: Double {
        preferences.useMetricSystem ? preferences.dailyGoal : preferences.dailyGoal * 0.033814
    }

    private func changeLanguage(to languageCode: String) {
        selectedLanguage = languageCode
        
        UserDefaults.standard.set(languageCode, forKey: "selectedLanguage")
        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        if let bundlePath = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
           let bundle = Bundle(path: bundlePath) {
            LocalizationManager.shared.currentBundle = bundle
        }
        
        NotificationCenter.default.post(name: Notification.Name("LanguageChanged"), object: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = UIHostingController(rootView: ContentView(selectedTab: $selectedTab))
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Water Intake Goal
                Section(header: Text("water_intake_goal".localized)) {
                    HStack {
                        Text("daily_target".localized)
                        Spacer()
                        Text(preferences.useMetricSystem ? "\(Int(preferences.dailyGoal)) ml" : String(format: "%.1f oz", goalInOz))
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $preferences.dailyGoal, 
                           in: preferences.useMetricSystem ? 1000...4000 : 33.8...135.2, 
                           step: preferences.useMetricSystem ? 50 : 1.69) { editing in
                        // Round to the suggested value when sliding ends
                        if !editing {
                            if preferences.useMetricSystem {
                                preferences.dailyGoal = round(preferences.dailyGoal / 50) * 50
                            } else {
                                preferences.dailyGoal = round(preferences.dailyGoal / 1.69) * 1.69
                            }
                        }
                    }
                    
                    HStack {
                        Text(String(format: "suggested_amount".localized + " %@",
                            preferences.useMetricSystem ?
                                "\(Int(preferences.suggestedWaterIntake)) ml" :
                                String(format: "%.1f oz", preferences.suggestedWaterIntake * 0.033814)))
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button("apply_suggestion".localized) {
                            preferences.dailyGoal = preferences.suggestedWaterIntake
                        }
                        .font(.footnote)
                    }
                }
                
                // Notifications
                Section(header: Text("notifications_section".localized)) {
                    Toggle("enable_notifications".localized, isOn: $preferences.notificationsEnabled)
                        .onChange(of: preferences.notificationsEnabled) { _, newValue in
                            if newValue {
                                notificationManager.requestAuthorization()
                            } else {
                                notificationManager.updateFromSettings(isEnabled: false, frequency: preferences.notificationFrequency)
                            }
                        }
                    
                    if preferences.notificationsEnabled {
                        Stepper(value: $preferences.notificationFrequency, in: 1...12) {
                            Text(String(format: "frequency_label".localized, preferences.notificationFrequency))
                        }
                        .onChange(of: preferences.notificationFrequency) { _, newValue in
                            if preferences.notificationsEnabled {
                                notificationManager.updateFromSettings(isEnabled: true, frequency: preferences.notificationFrequency)
                            }
                        }
                    }
                }
                .alert("notification_permission_denied_title".localized, isPresented: $showSettingsAlert) {
                    Button("open_settings".localized, role: .none) {
                        notificationManager.openAppSettings()
                    }
                    Button("cancel_button".localized, role: .cancel) { }
                } message: {
                    Text("notification_permission_message".localized)
                }
                
                // Profile
                Section(header: Text("profile_section".localized)) {
                    HStack {
                        Text("username_label".localized)
                        Spacer()
                        TextField("name_placeholder".localized, text: $preferences.username)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("height_label".localized)
                        Spacer()
                        TextField("height_placeholder".localized, value: $preferences.userHeight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text(preferences.useMetricSystem ? "cm_unit".localized : "inch_unit".localized)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("weight_label".localized)
                        Spacer()
                        TextField("weight_placeholder".localized, value: $preferences.userWeight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text(preferences.useMetricSystem ? "kg_unit".localized : "lb_unit".localized)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Appearance
                Section(header: Text("appearance_section".localized)) {
                    Toggle("dark_mode".localized, isOn: $preferences.isDarkMode)
                        .animation(.easeInOut, value: preferences.isDarkMode)
                }
                
                // Units
                Section(header: Text("units_section".localized)) {
                    Toggle("use_metric".localized, isOn: $preferences.useMetricSystem)
                        .onChange(of: preferences.useMetricSystem) { _, newValue in
                            preferences.convertUnits(toMetric: newValue)
                        }
                }

                // Language Settings
                Section(header: Text("language_section".localized)) {
                    Picker("language_section".localized, selection: $selectedLanguage) {
                        Text("English").tag("en")
                        Text("Türkçe").tag("tr")
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedLanguage) { _, newValue in
                        changeLanguage(to: newValue)
                    }
                }
                
                // About and Version
                Section(header: Text("about_section".localized)) {
                    HStack {
                        Text("app_version".localized)
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link("privacy_policy".localized, destination: URL(string: "https://example.com/privacy")!)
                    Link("terms_of_use".localized, destination: URL(string: "https://example.com/terms")!)
                }
            }
            .navigationTitle("settings_title".localized)
        }
    }
}

