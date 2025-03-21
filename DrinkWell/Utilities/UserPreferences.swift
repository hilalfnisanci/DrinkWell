//
//  UserPreferences.swift
//  DrinkWell
//
//  Created by Hilal on 18.03.2025.
//

import Foundation
import SwiftUI
import Combine

extension Notification.Name {
    static let themeDidChange = Notification.Name("themeDidChange")
}

class UserPreferences: ObservableObject {
    // Singleton instance
    static let shared = UserPreferences()
    
    // MARK: - Stored Properties
    
    @Published var selectedLanguage: String {
        didSet {
            UserDefaults.standard.set(selectedLanguage, forKey: "selectedLanguage")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: Notification.Name("LanguageChanged"), object: nil)
        }
    }

    // Daily Water Goal
    @Published var dailyGoal: Double {
        didSet {
            UserDefaults.standard.set(dailyGoal, forKey: Keys.dailyGoal.rawValue)
        }
    }
    
    // Notification Settings
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: Keys.notificationsEnabled.rawValue)
        }
    }
    
    @Published var notificationFrequency: Int {
        didSet {
            UserDefaults.standard.set(notificationFrequency, forKey: Keys.notificationFrequency.rawValue)
        }
    }
    
    // Appearance Settings
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: Keys.isDarkMode.rawValue)
            // Notify theme change
            NotificationCenter.default.post(name: .themeDidChange, object: nil)
        }
    }
    
    // Unit Preferences
    @Published var useMetricSystem: Bool {
        didSet {
            UserDefaults.standard.set(useMetricSystem, forKey: Keys.useMetricSystem.rawValue)
        }
    }
    
    // User Profile
    @Published var username: String {
        didSet {
            UserDefaults.standard.set(username, forKey: Keys.username.rawValue)
        }
    }
    
    @Published var userHeight: Double? {
        didSet {
            if let height = userHeight {
                UserDefaults.standard.set(height, forKey: Keys.userHeight.rawValue)
            } else {
                UserDefaults.standard.removeObject(forKey: Keys.userHeight.rawValue)
            }
        }
    }
    
    @Published var userWeight: Double? {
        didSet {
            if let weight = userWeight {
                UserDefaults.standard.set(weight, forKey: Keys.userWeight.rawValue)
            } else {
                UserDefaults.standard.removeObject(forKey: Keys.userWeight.rawValue)
            }
        }
    }
    
    // MARK: - Key Constants
    
    // Enum for key constants
    enum Keys: String {
        case dailyGoal
        case notificationsEnabled
        case notificationFrequency
        case isDarkMode
        case useMetricSystem
        case username
        case userHeight
        case userWeight
    }
    
    // MARK: - Initializer
    
    private init() {
        // Initialize all properties with default values
        self.dailyGoal = 2500
        self.notificationsEnabled = false
        self.notificationFrequency = 2
        self.isDarkMode = false
        self.useMetricSystem = true
        self.username = ""
        self.userHeight = nil
        self.userWeight = nil
        self.selectedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
        
        // Load values from UserDefaults
        if let savedDailyGoal = UserDefaults.standard.object(forKey: Keys.dailyGoal.rawValue) as? Double {
            self.dailyGoal = savedDailyGoal
        }
        
        if let savedNotificationsEnabled = UserDefaults.standard.object(forKey: Keys.notificationsEnabled.rawValue) as? Bool {
            self.notificationsEnabled = savedNotificationsEnabled
        }
        
        if let savedNotificationFrequency = UserDefaults.standard.object(forKey: Keys.notificationFrequency.rawValue) as? Int {
            self.notificationFrequency = savedNotificationFrequency
        }
        
        if let savedIsDarkMode = UserDefaults.standard.object(forKey: Keys.isDarkMode.rawValue) as? Bool {
            self.isDarkMode = savedIsDarkMode
        }
        
        if let savedUseMetricSystem = UserDefaults.standard.object(forKey: Keys.useMetricSystem.rawValue) as? Bool {
            self.useMetricSystem = savedUseMetricSystem
        }
        
        if let savedUsername = UserDefaults.standard.string(forKey: Keys.username.rawValue) {
            self.username = savedUsername
        }
        
        if let savedUserHeight = UserDefaults.standard.object(forKey: Keys.userHeight.rawValue) as? Double {
            self.userHeight = savedUserHeight
        }
        
        if let savedUserWeight = UserDefaults.standard.object(forKey: Keys.userWeight.rawValue) as? Double {
            self.userWeight = savedUserWeight
        }
    }
    
    // MARK: - Helper Methods
    
    // Reset all settings to default values
    func resetToDefaults() {
        dailyGoal = 2500
        notificationsEnabled = true
        notificationFrequency = 2
        isDarkMode = false
        useMetricSystem = true
        username = ""
        userHeight = nil
        userWeight = nil
    }
    
    // Convert measurements during unit change
    func convertUnits(toMetric: Bool) {
        if toMetric {
            // Convert from imperial to metric
            dailyGoal = dailyGoal * 29.5735 // oz to ml
            
            if let height = userHeight {
                userHeight = height * 2.54 // inches to cm
            }
            
            if let weight = userWeight {
                userWeight = weight * 0.453592 // pounds to kg
            }
        } else {
            // Convert from metric to imperial
            dailyGoal = dailyGoal * 0.033814 // ml to oz
            
            if let height = userHeight {
                userHeight = height / 2.54 // cm to inches
            }
            
            if let weight = userWeight {
                userWeight = weight / 0.453592 // kg to pounds
            }
        }
    }
    
    // Calculate recommended daily water intake
    var suggestedWaterIntake: Double {
        if let weight = userWeight {
            if useMetricSystem {
                return weight * 35 // ml (based on kg)
            } else {
                return weight * 0.5 // oz (based on pounds)
            }
        } else {
            return useMetricSystem ? 2500 : 84.5 // Varsayılan değerler (ml veya oz)
        }
    }
}