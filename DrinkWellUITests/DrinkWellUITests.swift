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
        
        // Set language to English for testing
        app.launchArguments = ["-AppleLanguages", "(en)"]
        
        // Force portrait orientation
        XCUIDevice.shared.orientation = .portrait
        
        app.launch()
    }
    
    override func tearDownWithError() throws {
        // Return to portrait orientation after each test
        XCUIDevice.shared.orientation = .portrait
    }
    
    func testOnboardingFlow() throws {
        // Log UI hierarchy for debugging
        print("Available UI Elements: \(app.debugDescription)")
        
        // Wait for app to fully load - check for any text element first
        let startupWait = XCTWaiter.wait(for: [XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == true"),
            object: app.staticTexts.element(boundBy: 0))], timeout: 10)
        XCTAssertEqual(startupWait, .completed, "App should display text elements")
        
        // Find welcome text by text content (more reliable than identifiers)
        let welcomeTextPredicate = NSPredicate(format: "label CONTAINS[c] 'welcome' OR label CONTAINS[c] 'hoş geldiniz'")
        let welcomeTitle = app.staticTexts.matching(welcomeTextPredicate).firstMatch
        XCTAssertTrue(welcomeTitle.waitForExistence(timeout: 10), "Welcome screen title should appear")
        
        // Find segmented control
        let segmentedControl = app.segmentedControls.firstMatch
        XCTAssertTrue(segmentedControl.waitForExistence(timeout: 5), "Language segmented control should be visible")
        
        // Find next button by text content
        let nextButtonPredicate = NSPredicate(format: "label CONTAINS[c] 'next' OR label CONTAINS[c] 'ileri'")
        let nextButton = app.buttons.matching(nextButtonPredicate).firstMatch
        XCTAssertTrue(nextButton.waitForExistence(timeout: 5), "Next button should be visible")
        nextButton.tap()
        
        // Wait for second page to load
        sleep(2)
        
        // Find text fields on personal info page - looking for any text field
        let nameField = app.textFields.firstMatch
        XCTAssertTrue(nameField.waitForExistence(timeout: 5), "Name field should be visible")
        nameField.tap()
        nameField.typeText("Test User")
        
        // Find next text field (height)
        let textFields = app.textFields.allElementsBoundByIndex
        guard textFields.count >= 2 else {
            XCTFail("Should have at least 2 text fields")
            return
        }
        
        let heightField = textFields[1]
        heightField.tap()
        heightField.clearText()
        sleep(2)
        
        // Find next text field (weight)
        guard textFields.count >= 3 else {
            XCTFail("Should have at least 3 text fields")
            return
        }
        
        let weightField = textFields[2]
        weightField.tap()
        weightField.clearText()
        sleep(2)
        
        let doneButton = app.buttons["Done"]
        if doneButton.exists {
            doneButton.tap()
        } else {
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9)).tap()
        }
        sleep(2)

        // Find and tap next button again (if it's enabled)
        let nextButton2 = app.buttons.matching(nextButtonPredicate).firstMatch
        XCTAssertTrue(nextButton2.waitForExistence(timeout: 5), "Next button should be visible on second page")
        
        if nextButton2.isEnabled {
            print("Form values - Name: \(nameField.value ?? "unknown"), Height: \(heightField.value ?? "unknown"), Weight: \(weightField.value ?? "unknown")")
            XCTFail("Next button is enabled but should be disabled when fields are empty.")
        } else {
            print("Form validation correctly disables Next button with empty fields")
        }

        heightField.tap()
        heightField.typeText("170")
        sleep(1)

        weightField.tap()
        weightField.typeText("70")
        sleep(1)

        if doneButton.exists {
            doneButton.tap()
        } else {
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9)).tap()
        }
        sleep(2)

        XCTAssertTrue(nextButton2.isEnabled, "Next button should be enabled after filling required fields")
        nextButton2.tap()
        
        // Wait a bit longer for the final page to fully load
        sleep(2)
        
        // Debug: Show what buttons are available on the screen
        print("Available buttons: \(app.buttons.allElementsBoundByIndex.map { $0.label })")
        
        // Try multiple ways to find the start button
        let startButtonPredicate = NSPredicate(format: "label CONTAINS[c] 'start' OR label CONTAINS[c] 'başla' OR label CONTAINS[c] 'başlat'")
        let startButton = app.buttons.matching(startButtonPredicate).firstMatch
        
        if !startButton.waitForExistence(timeout: 8) {
            // If we can't find by predicate, try by position (last button on screen)
            let allButtons = app.buttons.allElementsBoundByIndex
            if let lastButton = allButtons.last {
                print("Using last button as Start button: \(lastButton.label)")
                lastButton.tap()
            } else {
                XCTFail("No buttons found on final page")
            }
        } else {
            startButton.tap()
        }
    }
    
    func testAddWaterIntake() throws {
        // Complete onboarding first
        try testOnboardingFlow()
        
        // Wait for main screen to load
        sleep(2)
        
        // Find and tap add water button
        let addWaterButton = app.buttons["add_water_button"]
        XCTAssertTrue(addWaterButton.waitForExistence(timeout: 10), "Add water button should be visible")
        addWaterButton.tap()
        
        // Find and tap 250ml button
        let waterAmountButton = app.buttons["250ml"]
        XCTAssertTrue(waterAmountButton.waitForExistence(timeout: 5), "250ml button should be visible")
        waterAmountButton.tap()
        
        // Check progress text
        let progressText = app.staticTexts.element(matching: NSPredicate(format: "label CONTAINS[c] 'ml'"))
        XCTAssertTrue(progressText.waitForExistence(timeout: 5), "Progress text should be visible")
    }
    
    // Test landscape mode functionality
    func testLandscapeMode() throws {
        // Complete onboarding first
        try testOnboardingFlow()
        
        // Switch to landscape mode
        XCUIDevice.shared.orientation = .landscapeLeft
        
        // Verify UI elements are still accessible
        let addWaterButton = app.buttons["add_water_button"]
        XCTAssertTrue(addWaterButton.waitForExistence(timeout: 10), "Add water button should be visible in landscape")
    }
}

extension XCUIElement {

    func clearText() {

        guard let text = value as? String, !text.isEmpty else { return }
        
        tap()
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: text.count)
        typeText(deleteString)
    }
}
