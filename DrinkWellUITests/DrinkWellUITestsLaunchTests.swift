//
//  DrinkWellUITestsLaunchTests.swift
//  DrinkWellUITests
//
//  Created by Hilal on 18.03.2025.
//

import XCTest

final class DrinkWellUITestsLaunchTests: XCTestCase {
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        
        // Set language to English for testing
        app.launchArguments = ["-AppleLanguages", "(en)"]
        
        // Force portrait orientation
        XCUIDevice.shared.orientation = .portrait
        
        app.launch()

        // Wait longer for launch screen
        let launchScreen = app.otherElements["LaunchScreen"]
        XCTAssertTrue(launchScreen.waitForExistence(timeout: 10), "Launch screen should appear")
        
        // Take launch screen screenshot
        let launchScreenshot = XCTAttachment(screenshot: app.screenshot())
        launchScreenshot.name = "Launch Screen"
        launchScreenshot.lifetime = .keepAlways
        add(launchScreenshot)
        
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
