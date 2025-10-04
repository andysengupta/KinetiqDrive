//
//  CaptionClashTests.swift
//  Caption Clash Tests
//
//  Unit tests for core game logic, scoring, and token estimation
//

import XCTest
@testable import Caption_AI

final class CaptionClashTests: XCTestCase {
    
    // MARK: - Token Budget Tests
    
    func testTokenEstimation() {
        let shortText = "Hello world"
        let longText = String(repeating: "test ", count: 100)
        
        let shortTokens = AFMTokenBudget.estimateTokens(for: shortText)
        let longTokens = AFMTokenBudget.estimateTokens(for: longText)
        
        XCTAssertGreaterThan(shortTokens, 0)
        XCTAssertGreaterThan(longTokens, shortTokens)
    }
    
    func testBudgetFits() {
        let smallPrompt = 100
        let largePrompt = 3000
        let normalResponse = 500
        let largeResponse = 2000
        
        XCTAssertTrue(AFMTokenBudget.fitsInBudget(promptTokens: smallPrompt, maxResponseTokens: normalResponse))
        XCTAssertFalse(AFMTokenBudget.fitsInBudget(promptTokens: largePrompt, maxResponseTokens: largeResponse))
    }
    
    func testTokenTruncation() {
        let longText = String(repeating: "test ", count: 200)
        let truncated = AFMTokenBudget.truncate(longText, toTokens: 50)
        
        XCTAssertLessThan(truncated.count, longText.count)
        XCTAssertTrue(truncated.hasSuffix("..."))
    }
    
    // MARK: - Caption Validation Tests
    
    func testValidCaption() {
        let validCaption = "Cozy Morning Vibes"
        let result = AFMJudge.validateCaption(validCaption)
        
        XCTAssertTrue(result.isValid)
        XCTAssertEqual(result.cleaned, validCaption)
    }
    
    func testInvalidCaptionTooShort() {
        let shortCaption = "Hi There"
        let result = AFMJudge.validateCaption(shortCaption)
        
        XCTAssertFalse(result.isValid) // Only 2 words
    }
    
    func testInvalidCaptionTooLong() {
        let longCaption = "This Is A Very Long Caption"
        let result = AFMJudge.validateCaption(longCaption)
        
        XCTAssertFalse(result.isValid) // 6 words
    }
    
    func testCaptionWhitespace() {
        let messyCaption = "  Hello World Test  "
        let result = AFMJudge.validateCaption(messyCaption)
        
        XCTAssertTrue(result.isValid)
        XCTAssertEqual(result.cleaned, "Hello World Test")
    }
    
    // MARK: - Game Engine Tests
    
    func testScoreEmoji() async {
        let engine = GameEngine()
        
        XCTAssertEqual(engine.getScoreEmoji(for: 10), "🏆")
        XCTAssertEqual(engine.getScoreEmoji(for: 9), "🌟")
        XCTAssertEqual(engine.getScoreEmoji(for: 8), "✨")
        XCTAssertEqual(engine.getScoreEmoji(for: 5), "😐")
    }
    
    func testDetermineWinner() async {
        let engine = GameEngine()
        
        XCTAssertTrue(engine.determineWinner(score: 10))
        XCTAssertTrue(engine.determineWinner(score: 8))
        XCTAssertFalse(engine.determineWinner(score: 7))
        XCTAssertFalse(engine.determineWinner(score: 0))
    }
    
    func testEmptyStats() async {
        let engine = GameEngine()
        let stats = engine.calculateStats(from: [])
        
        XCTAssertEqual(stats.totalRounds, 0)
        XCTAssertEqual(stats.averageScore, 0)
        XCTAssertEqual(stats.highestScore, 0)
    }
    
    // MARK: - Badge Tests
    
    func testBadgeUnlockFirstLight() {
        let badge = Badge.firstLight
        let rounds: [RoundRecord] = [
            createMockRound(score: 9, userCaption: "Test One")
        ]
        
        let shouldUnlock = badge.checkUnlock(rounds: rounds, currentStreak: 0, uniqueImagesCount: 1)
        XCTAssertTrue(shouldUnlock)
    }
    
    func testBadgeLockFirstLight() {
        let badge = Badge.firstLight
        let rounds: [RoundRecord] = [
            createMockRound(score: 5, userCaption: "Test One")
        ]
        
        let shouldUnlock = badge.checkUnlock(rounds: rounds, currentStreak: 0, uniqueImagesCount: 1)
        XCTAssertFalse(shouldUnlock)
    }
    
    func testBadgeUnlockPerfectionist() {
        let badge = Badge.perfectionist
        let rounds: [RoundRecord] = [
            createMockRound(score: 7, userCaption: "Test One"),
            createMockRound(score: 10, userCaption: "Test Two"),
            createMockRound(score: 8, userCaption: "Test Three")
        ]
        
        let shouldUnlock = badge.checkUnlock(rounds: rounds, currentStreak: 0, uniqueImagesCount: 3)
        XCTAssertTrue(shouldUnlock)
    }
    
    func testBadgeUnlockStreaker() {
        let badge = Badge.streaker
        
        let shouldUnlock = badge.checkUnlock(rounds: [], currentStreak: 7, uniqueImagesCount: 0)
        XCTAssertTrue(shouldUnlock)
        
        let shouldNotUnlock = badge.checkUnlock(rounds: [], currentStreak: 5, uniqueImagesCount: 0)
        XCTAssertFalse(shouldNotUnlock)
    }
    
    // MARK: - Image Utils Tests
    
    func testImageDownscaling() {
        // Create a large test image
        let largeSize = CGSize(width: 4000, height: 3000)
        let renderer = UIGraphicsImageRenderer(size: largeSize)
        let largeImage = renderer.image { context in
            UIColor.blue.setFill()
            context.fill(CGRect(origin: .zero, size: largeSize))
        }
        
        let downscaled = ImageUtils.downscale(largeImage, maxDimension: 2048)
        
        XCTAssertLessThanOrEqual(downscaled.size.width, 2048)
        XCTAssertLessThanOrEqual(downscaled.size.height, 2048)
    }
    
    func testImageNoDownscaleNeeded() {
        let smallSize = CGSize(width: 500, height: 500)
        let renderer = UIGraphicsImageRenderer(size: smallSize)
        let smallImage = renderer.image { context in
            UIColor.red.setFill()
            context.fill(CGRect(origin: .zero, size: smallSize))
        }
        
        let result = ImageUtils.downscale(smallImage, maxDimension: 2048)
        
        XCTAssertEqual(result.size.width, 500)
        XCTAssertEqual(result.size.height, 500)
    }
    
    // MARK: - AFM Models Tests
    
    func testCaptionJudgmentWinner() {
        let highScore = CaptionJudgment(score: 9, shortTips: ["Great!"], categories: ["Relevance"])
        XCTAssertEqual(highScore.winner, .user)
        
        let lowScore = CaptionJudgment(score: 3, shortTips: ["Try again"], categories: ["Relevance"])
        XCTAssertEqual(lowScore.winner, .ai)
        
        let midScore = CaptionJudgment(score: 6, shortTips: ["Good"], categories: ["Relevance"])
        XCTAssertEqual(midScore.winner, .tie)
    }
    
    func testAICaptionValidation() {
        let validCaption = AICaption(caption: "Hello World Test")
        XCTAssertTrue(validCaption.isValid)
        XCTAssertEqual(validCaption.wordCount, 3)
        
        let shortCaption = AICaption(caption: "Hi There")
        XCTAssertFalse(shortCaption.isValid)
        
        let longCaption = AICaption(caption: "One Two Three Four Five Six")
        XCTAssertFalse(longCaption.isValid)
    }
    
    func testImageInterpretationMarkdown() {
        let interpretation = ImageInterpretation(
            objects: ["cat", "laptop"],
            scene: "A cat sitting on a laptop",
            actions: ["sitting"],
            vibes: ["cute", "funny"],
            altText: "Cat on laptop",
            safetyFlag: .none
        )
        
        let markdown = interpretation.markdownSummary
        
        XCTAssertTrue(markdown.contains("## Image Analysis"))
        XCTAssertTrue(markdown.contains("cat"))
        XCTAssertTrue(markdown.contains("laptop"))
    }
    
    // MARK: - Helper Methods
    
    private func createMockRound(score: Int, userCaption: String) -> RoundRecord {
        return RoundRecord(
            userCaption: userCaption,
            aiCaption: "AI Caption",
            score: score,
            tips: ["Tip 1"],
            categories: ["Test"],
            didUserWin: score >= 8,
            safetyFlag: "none"
        )
    }
}

