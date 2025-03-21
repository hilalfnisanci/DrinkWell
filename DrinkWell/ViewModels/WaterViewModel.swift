//
//  WaterViewModel.swift
//  DrinkWell
//
//  Created by Hilal on 18.03.2025.
//

import Foundation
import SwiftUI
import SwiftData
import WidgetKit

@MainActor
class WaterViewModel: ObservableObject {
    // Access via DataController
    private let dataController = DataController.shared
    private let preferences = UserPreferences.shared

    private enum WaterViewModelError: LocalizedError {
        case loadFailed
        case saveFailed
        case deleteFailed
        
        var errorDescription: String? {
            switch self {
            case .loadFailed:
                return "error_load_failed".localized
            case .saveFailed:
                return "error_save_failed".localized
            case .deleteFailed:
                return "error_delete_failed".localized
            }
        }
    }
    // Published properties
    @Published var waterIntakes: [WaterIntake] = []
    @Published var dailyGoal: Double {
        didSet {
            // Save to UserDefaults when goal changes
            UserDefaults.standard.set(dailyGoal, forKey: "dailyGoal")
        }
    }
    @Published var currentDate: Date = Date()
    
    // Computed properties
    var todaysTotal: Double {
        // Safely calculate using the active modelContext
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: currentDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<WaterIntake> { intake in
            intake.timestamp >= startOfDay && intake.timestamp < endOfDay
        }
        
        let descriptor = FetchDescriptor<WaterIntake>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        
        do {
            let intakes = try dataController.fetch(descriptor)
            return intakes.reduce(0) { $0 + $1.amount }
        } catch {
            print("❌ Error: Failed to calculate daily total: \(error.localizedDescription)")
            return 0
        }
    }

    var progress: Double {
        min(todaysTotal / dailyGoal, 1.0)
    }
    
    // MARK: - Initializer
    
    init() {        
        // Load daily goal from UserDefaults
        self.dailyGoal = preferences.dailyGoal
        if self.dailyGoal == 0 {
            // Default value
            self.dailyGoal = 2500
            UserDefaults.standard.set(self.dailyGoal, forKey: "dailyGoal")
        }
        
        // Set initial values for the widget
        let userDefaults = UserDefaults(suiteName: "group.com.hilalNisanci.DrinkWell")
        userDefaults?.set(todaysTotal, forKey: "todaysIntake")
        userDefaults?.set(dailyGoal, forKey: "dailyGoal")

        // Load data
        Task {
            await loadWaterIntakes()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: .themeDidChange, object: nil)
    }

    @objc private func refreshData() {
        Task {
            await loadWaterIntakes()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Data Handling Methods
    
    /// Loads all water intakes
    func loadWaterIntakes() async {
        do {
            let descriptor = FetchDescriptor<WaterIntake>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
            let fetchedIntakes = try dataController.fetch(descriptor)
            
            // Update UI on the main thread
            await MainActor.run {
                self.waterIntakes = fetchedIntakes
            }
        } catch {
            print("❌ Error: Failed to load water intakes: \(error.localizedDescription)")
        }
    }
    
    /// Filters today's water intakes
    func fetchTodaysIntakes() async -> [WaterIntake] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: currentDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<WaterIntake> { intake in
            intake.timestamp >= startOfDay && intake.timestamp < endOfDay
        }
        
        let descriptor = FetchDescriptor<WaterIntake>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        
        do {
            return try dataController.fetch(descriptor)
        } catch {
            print("❌ Error: Failed to fetch today's intakes: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Core Functions
    
    /// Adds a new water intake
    func addWaterIntake(amount: Double, note: String? = nil) async {
        let newIntake = WaterIntake(amount: amount, timestamp: currentDate, note: note)
        
        dataController.insert(newIntake)
        waterIntakes.insert(newIntake, at: 0)
        
        do {
            try dataController.save()
            await loadWaterIntakes() // Refresh the list
        } catch {
            print("❌ Error: \(WaterViewModelError.saveFailed.localizedDescription): \(error.localizedDescription)")
        }
        
        objectWillChange.send()

        // Update the widget
        let userDefaults = UserDefaults(suiteName: "group.com.hilalNisanci.DrinkWell")
        userDefaults?.set(todaysTotal, forKey: "todaysIntake")
        userDefaults?.set(dailyGoal, forKey: "dailyGoal")
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    /// Deletes a specific water intake
    func removeWaterIntake(at offsets: IndexSet) async {
        let todaysIntakes = await fetchTodaysIntakes()
        
        for index in offsets {
            if index < todaysIntakes.count {
                let intakeToDelete = todaysIntakes[index]
                dataController.delete(intakeToDelete)
                
                if let mainIndex = waterIntakes.firstIndex(where: { $0.id == intakeToDelete.id }) {
                    waterIntakes.remove(at: mainIndex)
                }
            }
        }
        
        do {
            try dataController.save()
            await loadWaterIntakes()
        } catch {
            print("❌ Error: \(WaterViewModelError.deleteFailed.localizedDescription): \(error.localizedDescription)")
        }
        
        objectWillChange.send()

        // Update the widget
        let userDefaults = UserDefaults(suiteName: "group.com.hilalNisanci.DrinkWell")
        userDefaults?.set(todaysTotal, forKey: "todaysIntake")
        userDefaults?.set(dailyGoal, forKey: "dailyGoal")
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    /// Handles date changes
    func setDate(_ date: Date) {
        currentDate = date
        objectWillChange.send() // Update UI
    }
    
    /// Updates the daily goal
    func updateDailyGoal(_ newGoal: Double) {
        preferences.dailyGoal = newGoal
        objectWillChange.send()
    }
}
