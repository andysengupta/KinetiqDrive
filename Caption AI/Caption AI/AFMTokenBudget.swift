//
//  AFMTokenBudget.swift
//  Caption Clash
//
//  Token estimation and budget management for Foundation Models
//  Helps stay within ~4k context window limits
//

import Foundation

struct AFMTokenBudget {
    // Conservative estimates (actual tokenizer may differ)
    static let contextWindow = 4096
    static let safetyBuffer = 512
    static let maxUsableTokens = contextWindow - safetyBuffer
    
    /// Rough token estimation (1 token ≈ 4 characters for English)
    static func estimateTokens(for text: String) -> Int {
        // Simplified: 1 token per ~4 chars
        return max(1, text.count / 4)
    }
    
    /// Check if prompt + expected response fits budget
    static func fitsInBudget(promptTokens: Int, maxResponseTokens: Int) -> Bool {
        return (promptTokens + maxResponseTokens) <= maxUsableTokens
    }
    
    /// Truncate text to fit token limit
    static func truncate(_ text: String, toTokens limit: Int) -> String {
        let maxChars = limit * 4
        if text.count <= maxChars {
            return text
        }
        let index = text.index(text.startIndex, offsetBy: maxChars)
        return String(text[..<index]) + "..."
    }
    
    /// Budget allocation for each stage
    struct StageBudgets {
        // Stage A: Image interpretation
        static let interpretPromptMax = 300
        static let interpretResponseMax = 800
        
        // Stage B: AI caption generation
        static let captionPromptMax = 600
        static let captionResponseMax = 50
        
        // Judge: Scoring
        static let judgePromptMax = 800
        static let judgeResponseMax = 200
    }
}

