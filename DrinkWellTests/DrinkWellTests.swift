//
//  DrinkWellTests.swift
//  DrinkWellTests
//
//  Created by Hilal on 18.03.2025.
//

import XCTest
import SwiftData
@testable import DrinkWell

@MainActor
final class DrinkWellTests: XCTestCase {
    var userPreferences: UserPreferences!
    var dataController: DataController!
    
    override func setUp() {
        super.setUp()
        userPreferences = UserPreferences.shared
        dataController = DataController.shared
    }
    
    override func tearDown() {
        userPreferences = nil
        dataController = nil
        super.tearDown()
    }
    
    func testWaterIntakeCalculation() throws {
        // Test daily water intake calculation
        userPreferences.userWeight = 70
        XCTAssertEqual(userPreferences.suggestedWaterIntake, 2450) // 70 * 35
    }
    
    func testLanguageSettings() throws {
        // Test language settings
        userPreferences.selectedLanguage = "en"
        XCTAssertEqual(UserDefaults.standard.string(forKey: "selectedLanguage"), "en")
    }
    
    func testDataStorage() throws {
        // Test water intake storage
        let intake = WaterIntake(amount: 250)
        
        do {
            dataController.insert(intake)
            try dataController.save()
            
            let descriptor = FetchDescriptor<WaterIntake>()
            let savedIntakes = try dataController.fetch(descriptor)
            XCTAssertTrue(savedIntakes.contains { $0.amount == 250 })
        } catch {
            XCTFail("Data storage test failed: \(error.localizedDescription)")
        }
    }
}
