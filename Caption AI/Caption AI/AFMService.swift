//
//  AFMService.swift
//  Caption Clash
//
//  Service layer for Apple Foundation Models (on-device LLM)
//  Handles availability checks, session management, and guided generation
//

import Foundation
import SwiftUI
import UIKit
import Combine

// Note: FoundationModels framework will be available on iOS 19+ with Apple Intelligence
// For now, this provides a complete structure with fallback for unavailability

@MainActor
final class AFMService: ObservableObject {
    
    // MARK: - Published State
    
    @Published var isAvailable: Bool = false
    @Published var availabilityStatus: String = "Checking..."
    @Published var lastError: String?
    
    // MARK: - Private State
    
    private var currentSession: Any? // SystemLanguageModel.Session when available
    private var checkTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    init() {
        // Availability check will happen on first use
    }
    
    deinit {
        checkTask?.cancel()
        // Note: cleanupSessions() is async, will be called automatically on dealloc
    }
    
    // MARK: - Availability Management
    
    func checkAvailability() async {
        checkTask?.cancel()
        checkTask = Task {
            await performAvailabilityCheck()
        }
        await checkTask?.value
    }
    
    private func performAvailabilityCheck() async {
        // Check for Apple Intelligence compatible device
        // iOS 19+ with Apple Intelligence: iPhone 15 Pro+, iPad with M1+
        let deviceCheck = await checkDeviceCompatibility()
        
        if !deviceCheck.isCompatible {
            isAvailable = false
            availabilityStatus = deviceCheck.reason
            return
        }
        
        // In production, check SystemLanguageModel.default.availability
        // For now, simulate based on device capability
        do {
            // Simulated check - replace with actual FoundationModels check:
            // let availability = await SystemLanguageModel.default.availability
            // switch availability {
            // case .available:
            //     isAvailable = true
            //     availabilityStatus = "Ready"
            // case .unavailable(let reason):
            //     isAvailable = false
            //     availabilityStatus = reason.description
            // }
            
            // Fallback: Assume unavailable until FoundationModels is imported
            isAvailable = false
            availabilityStatus = "AI model not available on this device. Manual mode enabled."
            lastError = nil
            
        } catch {
            isAvailable = false
            availabilityStatus = "Error checking AI availability"
            lastError = error.localizedDescription
        }
    }
    
    private func checkDeviceCompatibility() async -> (isCompatible: Bool, reason: String) {
        // Check iOS version
        let version = ProcessInfo.processInfo.operatingSystemVersion
        guard version.majorVersion >= 19 else {
            return (false, "Requires iOS 19 or later")
        }
        
        // Check device capability (simplified - actual check would use device identifier)
        // In production, verify A17+ chip or M1+ chip for Apple Intelligence
        return (true, "Device compatible")
    }
    
    // MARK: - Session Management
    
    func cleanupSessions() {
        currentSession = nil
    }
    
    private func createSession() throws {
        guard isAvailable else {
            throw AFMError.unavailable
        }
        
        // In production:
        // currentSession = try await SystemLanguageModel.default.createSession()
        
        // Fallback for now
        throw AFMError.unavailable
    }
    
    // MARK: - Stage A: Image Interpretation
    
    func interpretImage(_ image: UIImage) async throws -> ImageInterpretation {
        guard isAvailable else {
            throw AFMError.unavailable
        }
        
        // In production with FoundationModels:
        /*
        let session = try await SystemLanguageModel.default.createSession()
        
        let prompt = AFMJudge.buildInterpretationPrompt()
        
        let message = try Message(
            text: prompt,
            attachments: [.image(image)]
        )
        
        let options = GenerationOptions(
            temperature: 0.5,
            maximumResponseTokens: AFMTokenBudget.StageBudgets.interpretResponseMax
        )
        
        let result = try await session.generate(
            message,
            as: ImageInterpretation.self, // Guided generation
            options: options
        )
        
        return result
        */
        
        // Fallback: Return mock interpretation
        return generateMockInterpretation(for: image)
    }
    
    // MARK: - Stage B: AI Caption Generation
    
    func generateCaption(from interpretation: ImageInterpretation) async throws -> AICaption {
        guard isAvailable else {
            throw AFMError.unavailable
        }
        
        // In production with FoundationModels:
        /*
        let session = try await SystemLanguageModel.default.createSession()
        
        let prompt = AFMJudge.buildCaptionPrompt(interpretation: interpretation)
        
        let message = try Message(text: prompt)
        
        let options = GenerationOptions(
            temperature: 0.7,
            maximumResponseTokens: AFMTokenBudget.StageBudgets.captionResponseMax
        )
        
        let result = try await session.generate(
            message,
            as: AICaption.self,
            options: options
        )
        
        return result
        */
        
        // Fallback: Generate mock caption
        return generateMockCaption(from: interpretation)
    }
    
    // MARK: - Judge: Score Captions
    
    func judgeCaption(
        userCaption: String,
        aiCaption: String,
        interpretation: ImageInterpretation
    ) async throws -> CaptionJudgment {
        guard isAvailable else {
            throw AFMError.unavailable
        }
        
        // In production with FoundationModels:
        /*
        let session = try await SystemLanguageModel.default.createSession()
        
        let prompt = AFMJudge.buildJudgmentPrompt(
            userCaption: userCaption,
            aiCaption: aiCaption,
            interpretation: interpretation
        )
        
        let message = try Message(text: prompt)
        
        let options = GenerationOptions(
            temperature: 0.6,
            maximumResponseTokens: AFMTokenBudget.StageBudgets.judgeResponseMax
        )
        
        let result = try await session.generate(
            message,
            as: CaptionJudgment.self,
            options: options
        )
        
        // Sanitize tips if needed
        let sanitizedTips = AFMJudge.sanitizeTips(result.shortTips, safetyFlag: interpretation.safetyFlag)
        return CaptionJudgment(
            score: result.score,
            shortTips: sanitizedTips,
            categories: result.categories
        )
        */
        
        // Fallback: Generate mock judgment
        return generateMockJudgment(userCaption: userCaption, aiCaption: aiCaption, interpretation: interpretation)
    }
    
    // MARK: - Mock Implementations (Fallback)
    
    private func generateMockInterpretation(for image: UIImage) -> ImageInterpretation {
        // Simulate basic image analysis for fallback
        return ImageInterpretation(
            objects: ["image", "photo", "scene"],
            scene: "A captured moment in time",
            actions: ["displaying", "showing"],
            vibes: ["interesting", "visual"],
            altText: "An image selected for caption generation",
            safetyFlag: .none
        )
    }
    
    private func generateMockCaption(from interpretation: ImageInterpretation) -> AICaption {
        // Generate simple caption from interpretation
        let words = interpretation.objects.prefix(2) + interpretation.vibes.prefix(1)
        let caption = words.map { $0.capitalized }.joined(separator: " ")
        return AICaption(caption: caption.isEmpty ? "Visual Moment Captured" : caption)
    }
    
    private func generateMockJudgment(
        userCaption: String,
        aiCaption: String,
        interpretation: ImageInterpretation
    ) -> CaptionJudgment {
        // Simple heuristic scoring for fallback
        let wordCount = userCaption.split(separator: " ").count
        let hasVibeWords = interpretation.vibes.contains { vibe in
            userCaption.localizedCaseInsensitiveContains(vibe)
        }
        let hasObjectWords = interpretation.objects.contains { obj in
            userCaption.localizedCaseInsensitiveContains(obj)
        }
        
        var score = 5
        if wordCount >= 3 && wordCount <= 5 { score += 2 }
        if hasVibeWords { score += 1 }
        if hasObjectWords { score += 2 }
        score = min(10, max(0, score))
        
        let tips = [
            "Try using more specific visual details",
            "Consider the mood and atmosphere",
            "Keep it concise but evocative"
        ]
        
        return CaptionJudgment(
            score: score,
            shortTips: Array(tips.prefix(3)),
            categories: ["Relevance", "Specificity", "Creativity"]
        )
    }
}

// MARK: - Error Handling

enum AFMError: LocalizedError {
    case unavailable
    case modelNotDownloaded
    case sessionCreationFailed
    case generationFailed(String)
    case invalidOutput
    case tokenLimitExceeded
    
    var errorDescription: String? {
        switch self {
        case .unavailable:
            return "AI is not available on this device. Playing in manual mode."
        case .modelNotDownloaded:
            return "AI model not downloaded. Check Settings > Apple Intelligence."
        case .sessionCreationFailed:
            return "Failed to start AI session. Try again."
        case .generationFailed(let reason):
            return "AI generation failed: \(reason)"
        case .invalidOutput:
            return "AI returned unexpected output. Try again."
        case .tokenLimitExceeded:
            return "Input too large for AI processing."
        }
    }
}

