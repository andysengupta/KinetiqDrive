//
//  Models.swift
//  Caption Clash
//
//  SwiftData models for local-only persistence
//

import Foundation
import SwiftData
import UIKit

// MARK: - Round Record

@Model
final class RoundRecord {
    var id: UUID
    var timestamp: Date
    
    // Image stored as low-res thumbnail JPEG (privacy-conscious)
    @Attribute(.externalStorage) var thumbnailData: Data?
    
    // Captions
    var userCaption: String
    var aiCaption: String
    
    // Scoring
    var score: Int // 0-10
    var tips: [String] // Max 3 tips from AI
    var categories: [String] // e.g., ["Relevance", "Specificity"]
    
    // Metadata
    var didUserWin: Bool
    var safetyFlag: String // "none", "contains_people", etc.
    
    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        thumbnailData: Data? = nil,
        userCaption: String,
        aiCaption: String,
        score: Int,
        tips: [String] = [],
        categories: [String] = [],
        didUserWin: Bool = false,
        safetyFlag: String = "none"
    ) {
        self.id = id
        self.timestamp = timestamp
        self.thumbnailData = thumbnailData
        self.userCaption = userCaption
        self.aiCaption = aiCaption
        self.score = score
        self.tips = tips
        self.categories = categories
        self.didUserWin = didUserWin
        self.safetyFlag = safetyFlag
    }
    
    var thumbnail: UIImage? {
        guard let data = thumbnailData else { return nil }
        return UIImage(data: data)
    }
}

// MARK: - Badge State

@Model
final class BadgeState {
    var id: String // Badge identifier from BadgeCatalog
    var isUnlocked: Bool
    var unlockedDate: Date?
    var progress: Int // For progressive badges
    var isNew: Bool // For UI notifications
    
    init(
        id: String,
        isUnlocked: Bool = false,
        unlockedDate: Date? = nil,
        progress: Int = 0,
        isNew: Bool = false
    ) {
        self.id = id
        self.isUnlocked = isUnlocked
        self.unlockedDate = unlockedDate
        self.progress = progress
        self.isNew = isNew
    }
}

// MARK: - Game Stats (Computed from Records)

struct GameStats {
    var totalRounds: Int
    var averageScore: Double
    var highestScore: Int
    var perfectScores: Int // Count of 10s
    var currentStreak: Int
    var longestStreak: Int
    var winRate: Double // User vs AI
    
    static let empty = GameStats(
        totalRounds: 0,
        averageScore: 0,
        highestScore: 0,
        perfectScores: 0,
        currentStreak: 0,
        longestStreak: 0,
        winRate: 0
    )
}

