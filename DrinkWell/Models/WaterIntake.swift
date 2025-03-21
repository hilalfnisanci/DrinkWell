//
//  Item.swift
//  DrinkWell
//
//  Created by Hilal on 18.03.2025.
//

import Foundation
import SwiftData

@Model
final class WaterIntake {
    var amount: Double // in ml
    var timestamp: Date
    var note: String?
    
    var timeFormatted: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    init(amount: Double, timestamp: Date = Date(), note: String? = nil) {
        self.amount = amount
        self.timestamp = timestamp
        self.note = note
    }
}

// Extension for helper calculation methods
extension WaterIntake {
    // Filter water intakes within a specific date range (e.g., daily)
    static func filtered(intakes: [WaterIntake], from startDate: Date, to endDate: Date) -> [WaterIntake] {
        return intakes.filter { intake in
            intake.timestamp >= startDate && intake.timestamp <= endDate
        }
    }
    
    // Filter all water intakes for today
    static func todaysIntakes(intakes: [WaterIntake]) -> [WaterIntake] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return filtered(intakes: intakes, from: startOfDay, to: endOfDay)
    }
    
    // Calculate total water intake (in ml)
    static func totalAmount(intakes: [WaterIntake]) -> Double {
        return intakes.reduce(0) { total, intake in
            total + intake.amount
        }
    }
    
    // Calculate today's total water intake
    static func todaysTotalAmount(intakes: [WaterIntake]) -> Double {
        let todaysIntakes = todaysIntakes(intakes: intakes)
        return totalAmount(intakes: todaysIntakes)
    }
}
