//
//  DrinkWellUITestsLaunchTests.swift
//  DrinkWellUITests
//
//  Created by Hilal on 18.03.2025.
//

import XCTest

final class DrinkWellUITestsLaunchTests: XCTestCase {
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        false
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        
        // Set language to English for testing
        app.launchArguments = ["-AppleLanguages", "(en)", "-UITest_SlowAnimations"]
        
        // Force portrait orientation
        XCUIDevice.shared.orientation = .portrait
        
        app.launch()

        let initialScreenshot = XCTAttachment(screenshot: app.screenshot())
        initialScreenshot.name = "Initial Screen"
        initialScreenshot.lifetime = .keepAlways
        add(initialScreenshot)

        sleep(1)

        let secondScreenshot = XCTAttachment(screenshot: app.screenshot())
        secondScreenshot.name = "Second Screen"
        secondScreenshot.lifetime = .keepAlways
        add(secondScreenshot)

        // Wait for launch screen to disappear
        sleep(3)
        
        // Check onboarding screen
        let welcomeTitle = app.staticTexts["welcome_title"]
        XCTAssertTrue(welcomeTitle.waitForExistence(timeout: 10), "Welcome screen should appear")
        
        // Take onboarding screen screenshot
        let onboardingScreenshot = XCTAttachment(screenshot: app.screenshot())
        onboardingScreenshot.name = "Onboarding Screen"
        onboardingScreenshot.lifetime = .keepAlways
        add(onboardingScreenshot)
    }
    
    @MainActor
    func testLaunchPerformance() throws {
        if #available(iOS 13.0, *) {
            // Measure app launch metrics
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
