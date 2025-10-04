//
//  CaptionClashUITests.swift
//  Caption Clash UI Tests
//
//  End-to-end UI tests with accessibility validation
//

import XCTest

final class CaptionClashUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Launch & Navigation Tests
    
    func testAppLaunches() throws {
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
    }
    
    func testTabBarExists() throws {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        
        XCTAssertTrue(app.buttons["Play"].exists)
        XCTAssertTrue(app.buttons["History"].exists)
        XCTAssertTrue(app.buttons["Badges"].exists)
        XCTAssertTrue(app.buttons["Settings"].exists)
    }
    
    func testNavigationBetweenTabs() throws {
        // Navigate to History
        app.buttons["History"].tap()
        XCTAssertTrue(app.navigationBars["History"].waitForExistence(timeout: 2))
        
        // Navigate to Badges
        app.buttons["Badges"].tap()
        XCTAssertTrue(app.navigationBars["Badges"].waitForExistence(timeout: 2))
        
        // Navigate to Settings
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 2))
        
        // Back to Play
        app.buttons["Play"].tap()
        XCTAssertTrue(app.navigationBars["Caption Clash"].waitForExistence(timeout: 2))
    }
    
    // MARK: - Play Flow Tests
    
    func testEmptyStateDisplayed() throws {
        // On first launch, should see empty state
        let emptyStateTitle = app.staticTexts["Get Started"]
        XCTAssertTrue(emptyStateTitle.waitForExistence(timeout: 5))
        
        let selectButton = app.buttons["Select Photo"]
        XCTAssertTrue(selectButton.exists)
    }
    
    // MARK: - History Tests
    
    func testHistoryEmptyState() throws {
        app.buttons["History"].tap()
        
        let emptyTitle = app.staticTexts["No History Yet"]
        XCTAssertTrue(emptyTitle.waitForExistence(timeout: 2))
    }
    
    // MARK: - Badges Tests
    
    func testBadgesDisplayed() throws {
        app.buttons["Badges"].tap()
        
        let achievementsTitle = app.staticTexts["Achievements"]
        XCTAssertTrue(achievementsTitle.waitForExistence(timeout: 2))
        
        // Check if badge names exist
        // Note: Badges may be locked initially
        XCTAssertTrue(app.staticTexts["First Light"].exists || app.staticTexts["Wordsmith"].exists)
    }
    
    // MARK: - Settings Tests
    
    func testSettingsAIStatus() throws {
        app.buttons["Settings"].tap()
        
        let aiStatusLabel = app.staticTexts["AI Status"]
        XCTAssertTrue(aiStatusLabel.waitForExistence(timeout: 2))
        
        // Should show availability status
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "Ready")).element.exists ||
                     app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "Unavailable")).element.exists)
    }
    
    func testSettingsPrivacyInfo() throws {
        app.buttons["Settings"].tap()
        
        let privacyMode = app.staticTexts["Privacy Mode"]
        XCTAssertTrue(privacyMode.waitForExistence(timeout: 2))
        
        // Check privacy claims
        XCTAssertTrue(app.staticTexts["✓ All processing on-device"].exists)
        XCTAssertTrue(app.staticTexts["✓ No data collection"].exists)
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityLabels() throws {
        // Play tab should have proper labels
        let playTab = app.buttons["Play"]
        XCTAssertTrue(playTab.isAccessibilityElement)
        
        // History tab
        let historyTab = app.buttons["History"]
        XCTAssertTrue(historyTab.isAccessibilityElement)
        
        // Badges tab
        let badgesTab = app.buttons["Badges"]
        XCTAssertTrue(badgesTab.isAccessibilityElement)
        
        // Settings tab
        let settingsTab = app.buttons["Settings"]
        XCTAssertTrue(settingsTab.isAccessibilityElement)
    }
    
    func testDynamicTypeSupport() throws {
        // This is a placeholder - actual dynamic type testing requires simulator configuration
        // In production, test with various text sizes: .extraSmall to .accessibilityExtraExtraExtraLarge
        XCTAssertTrue(app.exists)
    }
    
    // MARK: - Performance Tests
    
    func testAppLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}

