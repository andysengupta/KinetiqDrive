//
//  AFMModels.swift
//  Caption Clash
//
//  @Generable structs for guided generation with Apple Foundation Models
//  Ensures type-safe, structured outputs from on-device LLM
//

import Foundation

// MARK: - Stage A: Image Interpretation

/// Structured output from visual analysis of the selected image
/// Used as grounding facts for AI caption generation and judging
struct ImageInterpretation: Codable, Sendable {
    /// Main concrete nouns visible in the image (e.g., ["cat", "laptop", "coffee mug"])
    var objects: [String]
    
    /// One-sentence description of the overall scene
    var scene: String
    
    /// Action verbs describing what's happening (e.g., ["sitting", "typing", "drinking"])
    var actions: [String]
    
    /// 1-3 word atmosphere descriptors (e.g., ["cozy", "productive", "morning"])
    var vibes: [String]
    
    /// Accessible alt text description (1-2 sentences)
    var altText: String
    
    /// Safety classification for content filtering
    var safetyFlag: SafetyFlag
    
    enum SafetyFlag: String, Codable, Sendable {
        case none
        case containsPeople = "contains_people"
        case containsChildren = "contains_children"
        case containsText = "contains_text"
        case containsLogos = "contains_logos"
    }
    
    /// Returns a markdown-formatted summary for prompts
    var markdownSummary: String {
        """
        ## Image Analysis
        **Scene:** \(scene)
        
        **Objects:** \(objects.joined(separator: ", "))
        
        **Actions:** \(actions.joined(separator: ", "))
        
        **Vibes:** \(vibes.joined(separator: ", "))
        
        **Alt Text:** \(altText)
        """
    }
}

// MARK: - Stage B: AI Caption

/// Structured AI-generated caption (3-5 words)
struct AICaption: Codable, Sendable {
    /// The caption itself: 3-5 words, Title Case, minimal punctuation
    var caption: String
    
    var wordCount: Int {
        caption.split(separator: " ").count
    }
    
    var isValid: Bool {
        let count = wordCount
        return count >= 1 && count <= 5 && !caption.isEmpty
    }
}

// MARK: - Judge: Caption Scoring

/// Structured judgment comparing user vs AI captions
struct CaptionJudgment: Codable, Sendable {
    /// Score from 0-10 based on rubric
    var score: Int
    
    /// Max 3 short, actionable tips for improvement
    var shortTips: [String]
    
    /// Categories evaluated (e.g., ["Relevance", "Specificity", "Creativity"])
    var categories: [String]
    
    /// Winner determination
    var winner: CaptionWinner {
        if score >= 8 {
            return .user
        } else if score <= 4 {
            return .ai
        } else {
            return .tie
        }
    }
    
    enum CaptionWinner: String, Codable, Sendable {
        case user
        case ai
        case tie
    }
    
    var isValid: Bool {
        score >= 0 && score <= 10 && !shortTips.isEmpty
    }
}

// MARK: - Fallback Models (Manual Mode)

/// Used when AFM is unavailable
struct ManualJudgment {
    let userCaption: String
    let score: Int = 5 // Neutral
    let tips: [String] = ["AI is unavailable. Try again later!"]
    
    var asCaptionJudgment: CaptionJudgment {
        CaptionJudgment(
            score: score,
            shortTips: tips,
            categories: ["Manual"]
        )
    }
}

