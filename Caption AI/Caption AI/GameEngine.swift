//
//  GameEngine.swift
//  Caption Clash
//
//  Core game logic: streaks, scoring, badge unlocks, statistics
//

import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
final class GameEngine: ObservableObject {
    
    // MARK: - Published State
    
    @Published var currentStreak: Int = 0
    @Published var newBadgesCount: Int = 0
    @Published var lastPlayedDate: Date?
    
    // MARK: - Streak Management
    
    func checkDailyStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        guard let lastPlayed = lastPlayedDate else {
            // First time playing
            return
        }
        
        let lastPlayedDay = calendar.startOfDay(for: lastPlayed)
        let daysDifference = calendar.dateComponents([.day], from: lastPlayedDay, to: today).day ?? 0
        
        if daysDifference > 1 {
            // Streak broken
            currentStreak = 0
        }
        // If daysDifference == 1, streak continues
        // If daysDifference == 0, already played today
    }
    
    func recordPlay() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastPlayed = lastPlayedDate {
            let lastPlayedDay = calendar.startOfDay(for: lastPlayed)
            let daysDifference = calendar.dateComponents([.day], from: lastPlayedDay, to: today).day ?? 0
            
            if daysDifference == 1 {
                // Consecutive day
                currentStreak += 1
            } else if daysDifference == 0 {
                // Already played today, no change
                return
            } else {
                // Gap in days, reset
                currentStreak = 1
            }
        } else {
            // First play
            currentStreak = 1
        }
        
        lastPlayedDate = Date()
    }
    
    // MARK: - Badge Management
    
    func checkBadgeUnlocks(
        context: ModelContext,
        rounds: [RoundRecord]
    ) async {
        let uniqueImagesCount = Set(rounds.compactMap { $0.thumbnailData }).count
        var newlyUnlocked: [Badge] = []
        
        for badge in Badge.allCases {
            // Fetch or create badge state
            let badgeId = badge.rawValue
            let descriptor = FetchDescriptor<BadgeState>(
                predicate: #Predicate<BadgeState> { state in
                    state.id == badgeId
                }
            )
            
            let existingStates = try? context.fetch(descriptor)
            let badgeState = existingStates?.first ?? {
                let state = BadgeState(id: badge.rawValue)
                context.insert(state)
                return state
            }()
            
            // Check unlock
            if !badgeState.isUnlocked {
                let shouldUnlock = badge.checkUnlock(
                    rounds: rounds,
                    currentStreak: currentStreak,
                    uniqueImagesCount: uniqueImagesCount
                )
                
                if shouldUnlock {
                    badgeState.isUnlocked = true
                    badgeState.unlockedDate = Date()
                    badgeState.isNew = true
                    newlyUnlocked.append(badge)
                }
            }
        }
        
        if !newlyUnlocked.isEmpty {
            newBadgesCount += newlyUnlocked.count
            Haptics.heavyImpact()
        }
    }
    
    func clearNewBadges(context: ModelContext) {
        let descriptor = FetchDescriptor<BadgeState>(
            predicate: #Predicate { $0.isNew == true }
        )
        
        if let badges = try? context.fetch(descriptor) {
            for badge in badges {
                badge.isNew = false
            }
        }
        
        newBadgesCount = 0
    }
    
    // MARK: - Statistics
    
    func calculateStats(from rounds: [RoundRecord]) -> GameStats {
        guard !rounds.isEmpty else {
            return .empty
        }
        
        let totalRounds = rounds.count
        let totalScore = rounds.reduce(0) { $0 + $1.score }
        let averageScore = Double(totalScore) / Double(totalRounds)
        let highestScore = rounds.map { $0.score }.max() ?? 0
        let perfectScores = rounds.filter { $0.score == 10 }.count
        let wins = rounds.filter { $0.didUserWin }.count
        let winRate = Double(wins) / Double(totalRounds)
        
        return GameStats(
            totalRounds: totalRounds,
            averageScore: averageScore,
            highestScore: highestScore,
            perfectScores: perfectScores,
            currentStreak: currentStreak,
            longestStreak: currentStreak, // Simplified
            winRate: winRate
        )
    }
    
    // MARK: - Scoring Logic
    
    func determineWinner(score: Int) -> Bool {
        // User wins if score >= 8
        return score >= 8
    }
    
    func getScoreEmoji(for score: Int) -> String {
        switch score {
        case 10: return "🏆"
        case 9: return "🌟"
        case 8: return "✨"
        case 6...7: return "👍"
        case 4...5: return "😐"
        default: return "💭"
        }
    }
    
    func getScoreMessage(for score: Int) -> String {
        switch score {
        case 10: return "Perfect! Absolute mastery!"
        case 9: return "Outstanding! Almost perfect!"
        case 8: return "Excellent work! You win!"
        case 6...7: return "Good effort! Keep trying!"
        case 4...5: return "Not bad, but try harder!"
        default: return "Keep practicing!"
        }
    }
}

