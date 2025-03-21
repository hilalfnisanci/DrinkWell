//
//  DrinkWellUITests.swift
//  DrinkWellUITests
//
//  Created by Hilal on 18.03.2025.
//
import XCTest

final class DrinkWellUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testOnboardingFlow() throws {
        // Test first launch onboarding
        let welcomeTitle = app.staticTexts["welcome_title"]
        XCTAssertTrue(welcomeTitle.exists)
        
        // Language selection
        let languagePicker = app.pickers["language_section"]
        XCTAssertTrue(languagePicker.exists)
        
        // Navigate through onboarding
        app.buttons["next_button"].tap()
        
        // Fill personal info
        let nameField = app.textFields["name_placeholder"]
        nameField.tap()
        nameField.typeText("Test User")
        
        let heightField = app.textFields["height_placeholder"]
        heightField.tap()
        heightField.typeText("170")
        
        let weightField = app.textFields["weight_placeholder"]
        weightField.tap()
        weightField.typeText("70")
        
        app.buttons["next_button"].tap()
        app.buttons["start_button"].tap()
    }
    
    func testAddWaterIntake() throws {
        // Test adding water intake
        app.buttons["add_water_button"].tap()
        app.buttons["250ml"].tap()
        
        // Verify water intake is added
        let progressText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'ml'")).firstMatch
        XCTAssertTrue(progressText.exists)
    }
}
