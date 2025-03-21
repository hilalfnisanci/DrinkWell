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
        
        // Set the language to English for the test
        app.launchArguments = ["-AppleLanguages", "(en)"]
        app.launch()

        // Wait for the launch screen to appear
        let launchScreenWait = XCTWaiter.wait(for: [
            XCTNSPredicateExpectation(
                predicate: NSPredicate(format: "exists == true"),
                object: app.otherElements["LaunchScreen"]
            )
        ], timeout: 2.0)
        
        XCTAssertEqual(launchScreenWait, .completed, "Launch screen should be visible")

        // Take a screenshot of the launch screen
        let launchScreenshot = XCTAttachment(screenshot: app.screenshot())
        launchScreenshot.name = "Launch Screen"
        launchScreenshot.lifetime = .keepAlways
        add(launchScreenshot)
        
        // Wait for the launch screen to disappear (2 seconds)
        Thread.sleep(forTimeInterval: 2)
        
        // Check the onboarding screen for the first launch
        let welcomeTitle = app.staticTexts["welcome_title"]
        XCTAssertTrue(welcomeTitle.exists, "Welcome screen should be visible for first launch")
        
        // Take a screenshot of the onboarding screen
        let onboardingScreenshot = XCTAttachment(screenshot: app.screenshot())
        onboardingScreenshot.name = "Onboarding Screen"
        onboardingScreenshot.lifetime = .keepAlways
        add(onboardingScreenshot)
    }
    
    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}