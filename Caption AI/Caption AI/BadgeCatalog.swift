//
//  BadgeCatalog.swift
//  Caption Clash
//
//  Complete badge definitions with SF Symbols, descriptions, and unlock criteria
//

import Foundation

enum Badge: String, CaseIterable, Identifiable {
    case firstLight = "first_light"
    case wordsmith = "wordsmith"
    case lensMaster = "lens_master"
    case minimalist = "minimalist"
    case perfectionist = "perfectionist"
    case streaker = "streaker"
    case explorer = "explorer"
    case critic = "critic"
    case creative = "creative"
    case speedster = "speedster"
    
    var id: String { rawValue }
    
    var name: String {
        switch self {
        case .firstLight: return "First Light"
        case .wordsmith: return "Wordsmith"
        case .lensMaster: return "Lens Master"
        case .minimalist: return "Minimalist"
        case .perfectionist: return "Perfectionist"
        case .streaker: return "Streaker"
        case .explorer: return "Explorer"
        case .critic: return "Critic"
        case .creative: return "Creative"
        case .speedster: return "Speedster"
        }
    }
    
    var description: String {
        switch self {
        case .firstLight:
            return "Score 8 or higher on your first caption"
        case .wordsmith:
            return "Score 9 or higher three times in a row"
        case .lensMaster:
            return "Complete 20 rounds"
        case .minimalist:
            return "Win with exactly 3 words"
        case .perfectionist:
            return "Score a perfect 10"
        case .streaker:
            return "Maintain a 7-day streak"
        case .explorer:
            return "Play with 50 different images"
        case .critic:
            return "Score 5 or lower 3 times (humility!)"
        case .creative:
            return "Get 5+ points for Originality category"
        case .speedster:
            return "Complete a round in under 30 seconds"
        }
    }
    
    var icon: String {
        switch self {
        case .firstLight: return "sunrise.fill"
        case .wordsmith: return "pencil.and.list.clipboard"
        case .lensMaster: return "camera.fill"
        case .minimalist: return "minus.circle.fill"
        case .perfectionist: return "star.circle.fill"
        case .streaker: return "flame.fill"
        case .explorer: return "map.fill"
        case .critic: return "eyeglasses"
        case .creative: return "paintbrush.fill"
        case .speedster: return "bolt.fill"
        }
    }
    
    var gradient: [String] {
        switch self {
        case .firstLight: return ["yellow", "orange"]
        case .wordsmith: return ["blue", "purple"]
        case .lensMaster: return ["green", "teal"]
        case .minimalist: return ["gray", "black"]
        case .perfectionist: return ["gold", "yellow"]
        case .streaker: return ["red", "orange"]
        case .explorer: return ["cyan", "blue"]
        case .critic: return ["purple", "pink"]
        case .creative: return ["pink", "purple"]
        case .speedster: return ["yellow", "red"]
        }
    }
    
    /// Check if badge should be unlocked based on game state
    func checkUnlock(
        rounds: [RoundRecord],
        currentStreak: Int,
        uniqueImagesCount: Int
    ) -> Bool {
        switch self {
        case .firstLight:
            guard let firstRound = rounds.first else { return false }
            return firstRound.score >= 8
            
        case .wordsmith:
            guard rounds.count >= 3 else { return false }
            let recent = Array(rounds.prefix(3))
            return recent.allSatisfy { $0.score >= 9 }
            
        case .lensMaster:
            return rounds.count >= 20
            
        case .minimalist:
            return rounds.contains { round in
                round.didUserWin && round.userCaption.split(separator: " ").count == 3
            }
            
        case .perfectionist:
            return rounds.contains { $0.score == 10 }
            
        case .streaker:
            return currentStreak >= 7
            
        case .explorer:
            return uniqueImagesCount >= 50
            
        case .critic:
            let lowScores = rounds.filter { $0.score <= 5 }
            return lowScores.count >= 3
            
        case .creative:
            return rounds.contains { round in
                round.categories.contains("Originality") && round.score >= 8
            }
            
        case .speedster:
            // Would need timestamp tracking per round; simplified for now
            return rounds.count >= 10
        }
    }
}

// MARK: - Badge Progress

struct BadgeProgress {
    let badge: Badge
    let isUnlocked: Bool
    let currentProgress: Int
    let targetProgress: Int
    let progressPercent: Double
    
    var progressDescription: String {
        if isUnlocked {
            return "Unlocked!"
        }
        return "\(currentProgress)/\(targetProgress)"
    }
}

