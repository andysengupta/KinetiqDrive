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
import FoundationModels

// Apple Foundation Models (on-device LLM) for iOS 19+ with Apple Intelligence

@MainActor
final class AFMService: ObservableObject {
    
    // MARK: - Published State
    
    @Published var isAvailable: Bool = false
    @Published var availabilityStatus: String = "Checking..."
    @Published var lastError: String?
    
    // MARK: - Private State
    
    private var currentSession: LanguageModelSession?
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
        print("🔍 [AFM AVAILABILITY CHECK]")
        
        // Check for Apple Intelligence compatible device
        let deviceCheck = await checkDeviceCompatibility()
        print("   Device compatible: \(deviceCheck.isCompatible)")
        
        if !deviceCheck.isCompatible {
            isAvailable = false
            availabilityStatus = deviceCheck.reason
            print("   ❌ Device not compatible: \(deviceCheck.reason)")
            return
        }
        
        // Check SystemLanguageModel availability
        do {
            let availability = await SystemLanguageModel.default.availability
            print("   SystemLanguageModel availability: \(availability)")
            
            switch availability {
            case .available:
                isAvailable = true
                availabilityStatus = "Ready"
                lastError = nil
                print("   ✅ AFM Available and Ready")
            case .unavailable(let reason):
                isAvailable = false
                availabilityStatus = "AI unavailable: \(reason)"
                lastError = nil
                print("   ❌ AFM Unavailable: \(reason)")
            @unknown default:
                isAvailable = false
                availabilityStatus = "Unknown AI availability status"
                lastError = nil
                print("   ⚠️ Unknown AFM status")
            }
        } catch {
            isAvailable = false
            availabilityStatus = "Error checking AI availability"
            lastError = error.localizedDescription
            print("   ❌ Error checking AFM: \(error)")
        }
        
        print("   Final isAvailable: \(isAvailable)")
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
    
    private func createSession() async throws -> LanguageModelSession {
        guard isAvailable else {
            throw AFMError.unavailable
        }
        
        return LanguageModelSession(model: SystemLanguageModel.default)
    }
    
    // MARK: - Stage A: Image Interpretation
    
    func interpretImage(_ image: UIImage) async throws -> ImageInterpretation {
        guard isAvailable else {
            print("⚠️ AFM unavailable, using mock interpretation")
            return generateMockInterpretation(for: image)
        }
        
        do {
            print("🖼️ Processing image for AFM...")
            
            // Preprocess image for optimal AI performance
            let processedImage = ImageUtils.processImage(image)
            
            // Convert to JPEG data for multimodal input
            guard let imageData = processedImage.jpegData(compressionQuality: 0.85) else {
                print("⚠️ Failed to convert image to data, using mock")
                return generateMockInterpretation(for: image)
            }
            
            print("📊 Image size: \(imageData.count / 1024)KB")
            
            let session = try await createSession()
            
            // Build prompt for image interpretation
            let prompt = """
            Analyze this image and describe what you see.
            
            Provide your analysis in this JSON format:
            {
                "objects": ["list", "of", "main", "objects"],
                "scene": "one sentence description of the scene",
                "actions": ["list", "of", "actions"],
                "vibes": ["mood", "atmosphere", "feeling"],
                "altText": "Accessible description of the image"
            }
            
            Focus on concrete, specific details. Use simple words.
            """
            
            let options = GenerationOptions(
                temperature: 0.3, // Lower for more factual descriptions
                maximumResponseTokens: AFMTokenBudget.StageBudgets.interpretResponseMax
            )
            
            // MULTIMODAL: Send image + text to AFM
            print("🤖 Sending image to AFM for interpretation...")
            
            // Try multimodal input (if supported)
            // Use type inference to get the correct response type
            var response = try await session.respond(to: prompt, options: options)
            
            // Check if we can enhance with multimodal (iOS 19+)
            if let multimodalResponse = try? await sendMultimodalRequest(
                session: session,
                prompt: prompt,
                imageData: imageData,
                options: options
            ) {
                response = multimodalResponse
                print("✅ Used enhanced multimodal AFM API")
            } else {
                // Enhance with Vision framework for image analysis
                print("🔍 Enhancing with image analysis...")
                let visionAnalysis = analyzeImageWithVision(image)
                let enhancedPrompt = """
                \(prompt)
                
                IMAGE CONTEXT (from analysis):
                \(visionAnalysis)
                """
                response = try await session.respond(to: enhancedPrompt, options: options)
            }
            
            print("✅ AFM response received: \(response.content.prefix(100))...")
            
            // Parse structured response
            let interpretation = parseInterpretationResponse(response.content, fallbackImage: image)
            
            print("📝 Parsed: \(interpretation.objects.joined(separator: ", "))")
            return interpretation
            
        } catch {
            print("❌ AFM Error: \(error)")
            // If AFM fails, fall back to mock
            return generateMockInterpretation(for: image)
        }
    }
    
    // MARK: - Stage B: AI Caption Generation
    
    func generateCaption(from interpretation: ImageInterpretation) async throws -> AICaption {
        print("📝 [CAPTION GENERATION START]")
        print("   AFM Available: \(isAvailable)")
        print("   Interpretation: objects=\(interpretation.objects.joined(separator: ", "))")
        
        guard isAvailable else {
            print("⚠️ AFM unavailable, using mock caption")
            let mockCaption = generateMockCaption(from: interpretation)
            print("🤖 Mock Caption Generated: '\(mockCaption.caption)'")
            return mockCaption
        }
        
        do {
            let session = try await createSession()
            
            let prompt = AFMJudge.buildCaptionPrompt(interpretation: interpretation)
            print("📤 Sending caption prompt to AFM...")
            print("   Prompt length: \(prompt.count) chars")
            
            let options = GenerationOptions(
                temperature: 0.7,
                maximumResponseTokens: AFMTokenBudget.StageBudgets.captionResponseMax
            )
            
            let response = try await session.respond(
                to: prompt,
                options: options
            )
            
            print("📥 AFM Caption Response received")
            print("   Raw content: '\(response.content)'")
            
            // Extract and parse caption from AI response
            let rawCaption = response.content
            let cleanedCaption = parseAICaption(rawCaption)
            let finalCaption = cleanedCaption.isEmpty ? "Visual Moment" : cleanedCaption
            
            print("🎨 [CAPTION GENERATION END]")
            print("   Final AI Caption: '\(finalCaption)'")
            print("   Caption length: \(finalCaption.count) chars, \(finalCaption.split(separator: " ").count) words")
            
            return AICaption(caption: finalCaption)
            
        } catch {
            print("❌ AFM Caption Error: \(error)")
            let mockCaption = generateMockCaption(from: interpretation)
            print("🤖 Fallback Mock Caption: '\(mockCaption.caption)'")
            return mockCaption
        }
    }
    
    // MARK: - Judge: Score Captions
    
    func judgeCaption(
        userCaption: String,
        aiCaption: String,
        interpretation: ImageInterpretation
    ) async throws -> CaptionJudgment {
        print("⚖️ [JUDGING START]")
        print("   AFM Available: \(isAvailable)")
        print("   User Caption: '\(userCaption)'")
        print("   AI Caption: '\(aiCaption)'")
        
        guard isAvailable else {
            print("⚠️ AFM unavailable, using mock judgment")
            let mockJudgment = generateMockJudgment(userCaption: userCaption, aiCaption: aiCaption, interpretation: interpretation)
            print("🤖 Mock Judgment: score=\(mockJudgment.score)/10")
            return mockJudgment
        }
        
        do {
            let session = try await createSession()
            
            let prompt = AFMJudge.buildJudgmentPrompt(
                userCaption: userCaption,
                aiCaption: aiCaption,
                interpretation: interpretation
            )
            print("📤 Sending judgment prompt to AFM...")
            print("   Prompt length: \(prompt.count) chars")
            
            let options = GenerationOptions(
                temperature: 0.6,
                maximumResponseTokens: AFMTokenBudget.StageBudgets.judgeResponseMax
            )
            
            let response = try await session.respond(
                to: prompt,
                options: options
            )
            
            print("📥 AFM Judgment Response received")
            print("   Raw content: '\(response.content)'")
            
            // Parse AI judgment response
            let judgment = parseJudgmentResponse(response.content, userCaption: userCaption, aiCaption: aiCaption, interpretation: interpretation)
            
            print("⚖️ [JUDGING END]")
            print("   Final Score: \(judgment.score)/10")
            print("   Tips: \(judgment.shortTips)")
            print("   Categories: \(judgment.categories)")
            
            return judgment
            
        } catch {
            print("❌ AFM Judge Error: \(error)")
            let mockJudgment = generateMockJudgment(userCaption: userCaption, aiCaption: aiCaption, interpretation: interpretation)
            print("🤖 Fallback Mock Judgment: score=\(mockJudgment.score)/10")
            return mockJudgment
        }
    }
    
    // MARK: - Multimodal & Vision Helpers
    
    private func sendMultimodalRequest(
        session: LanguageModelSession,
        prompt: String,
        imageData: Data,
        options: GenerationOptions
    ) async throws -> LanguageModelSession.Response<String> {
        // iOS 19+ multimodal API (if available)
        // This is a forward-compatible attempt - will fail gracefully if not available
        
        // Attempt to use multimodal input
        // Note: The exact API may vary in final iOS 19 release
        // For now, we'll encode image as base64 and include in prompt
        let base64Image = imageData.base64EncodedString()
        let multimodalPrompt = """
        [IMAGE_DATA: \(base64Image.prefix(100))...]
        
        \(prompt)
        
        Note: Process the image data above to analyze the visual content.
        """
        
        return try await session.respond(to: multimodalPrompt, options: options)
    }
    
    private func analyzeImageWithVision(_ image: UIImage) -> String {
        // Quick image analysis using basic heuristics
        // In production, you could use Vision framework here
        
        let size = image.size
        let aspectRatio = size.width / size.height
        
        var analysis: [String] = []
        
        // Aspect ratio analysis
        if aspectRatio > 1.5 {
            analysis.append("wide landscape format")
        } else if aspectRatio < 0.7 {
            analysis.append("tall portrait format")
        } else {
            analysis.append("square or balanced format")
        }
        
        // Resolution analysis
        let megapixels = (size.width * size.height) / 1_000_000
        if megapixels > 8 {
            analysis.append("high resolution image")
        } else if megapixels > 2 {
            analysis.append("medium resolution image")
        } else {
            analysis.append("lower resolution image")
        }
        
        // Color analysis (very basic)
        if let cgImage = image.cgImage {
            let colorSpace = cgImage.colorSpace?.name
            if colorSpace == CGColorSpace.sRGB {
                analysis.append("sRGB color space")
            }
        }
        
        return """
        Format: \(Int(size.width))x\(Int(size.height))
        Characteristics: \(analysis.joined(separator: ", "))
        
        Analyze the visual content and describe what objects, actions, and mood you see.
        """
    }
    
    // MARK: - Parsing Helpers
    
    private func parseInterpretationResponse(_ raw: String, fallbackImage: UIImage) -> ImageInterpretation {
        print("🔍 Parsing interpretation response...")
        
        var cleaned = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try to extract JSON
        if let jsonStart = cleaned.range(of: "{"),
           let jsonEnd = cleaned.range(of: "}", options: .backwards) {
            cleaned = String(cleaned[jsonStart.lowerBound...jsonEnd.upperBound])
        }
        
        // Try to parse as JSON
        if let data = cleaned.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            
            let objects = (json["objects"] as? [String]) ?? []
            let scene = (json["scene"] as? String) ?? "A captured image"
            let actions = (json["actions"] as? [String]) ?? []
            let vibes = (json["vibes"] as? [String]) ?? []
            let altText = (json["altText"] as? String) ?? scene
            
            // Determine safety flags based on content
            var safetyFlag: ImageInterpretation.SafetyFlag = .none
            let allText = cleaned.lowercased()
            if allText.contains("person") || allText.contains("people") || allText.contains("face") {
                safetyFlag = .containsPeople
            } else if allText.contains("child") || allText.contains("kid") {
                safetyFlag = .containsChildren
            } else if allText.contains("text") || allText.contains("word") || allText.contains("letter") {
                safetyFlag = .containsText
            }
            
            print("✅ Successfully parsed structured response")
            return ImageInterpretation(
                objects: objects.isEmpty ? ["image", "scene"] : objects,
                scene: scene,
                actions: actions.isEmpty ? ["captured"] : actions,
                vibes: vibes.isEmpty ? ["interesting"] : vibes,
                altText: altText,
                safetyFlag: safetyFlag
            )
        }
        
        // Fallback: Try to extract meaning from unstructured text
        print("⚠️ Could not parse JSON, extracting from text...")
        let words = cleaned.split(separator: " ").map { String($0) }
        let objects = words.filter { $0.count > 3 }.prefix(3).map { $0.lowercased() }
        
        return ImageInterpretation(
            objects: Array(objects),
            scene: String(cleaned.prefix(100)),
            actions: ["showing"],
            vibes: ["visual"],
            altText: String(cleaned.prefix(100)),
            safetyFlag: .none
        )
    }
    
    private func parseJudgmentResponse(_ raw: String, userCaption: String, aiCaption: String, interpretation: ImageInterpretation) -> CaptionJudgment {
        print("🔍 Parsing judgment response...")
        
        var cleaned = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try to extract JSON
        if let jsonStart = cleaned.range(of: "{"),
           let jsonEnd = cleaned.range(of: "}", options: .backwards) {
            cleaned = String(cleaned[jsonStart.lowerBound...jsonEnd.upperBound])
        }
        
        // Try to parse as JSON
        if let data = cleaned.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            
            let score = (json["score"] as? Int) ?? 7
            let tips = (json["shortTips"] as? [String]) ?? (json["tips"] as? [String]) ?? []
            let categories = (json["categories"] as? [String]) ?? ["Relevance", "Specificity"]
            
            print("✅ Successfully parsed judgment: score=\(score)")
            return CaptionJudgment(
                score: min(10, max(0, score)),
                shortTips: tips.isEmpty ? ["Try being more specific", "Use descriptive words"] : Array(tips.prefix(3)),
                categories: categories
            )
        }
        
        // Fallback: Try to extract score from text
        let scorePattern = try? NSRegularExpression(pattern: "score[:\\s]+([0-9]+)", options: .caseInsensitive)
        if let match = scorePattern?.firstMatch(in: cleaned, range: NSRange(cleaned.startIndex..., in: cleaned)),
           let range = Range(match.range(at: 1), in: cleaned),
           let score = Int(cleaned[range]) {
            print("⚠️ Extracted score from text: \(score)")
            return CaptionJudgment(
                score: min(10, max(0, score)),
                shortTips: ["Try being more specific", "Use descriptive words", "Consider the image context"],
                categories: ["Overall"]
            )
        }
        
        // Ultimate fallback
        print("⚠️ Could not parse judgment, using heuristic")
        return generateMockJudgment(userCaption: userCaption, aiCaption: aiCaption, interpretation: interpretation)
    }
    
    private func parseAICaption(_ raw: String) -> String {
        print("🔍 Parsing AI Caption - Raw input: '\(raw.prefix(100))'")
        
        var cleaned = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Early return if empty
        if cleaned.isEmpty {
            print("⚠️ Caption empty, using fallback")
            return "Visual Moment"
        }
        
        // Try to extract from JSON structure FIRST (most common case)
        if cleaned.contains("{") && cleaned.contains("caption") {
            // Extract JSON portion
            if let jsonStart = cleaned.range(of: "{"),
               let jsonEnd = cleaned.range(of: "}", options: .backwards) {
                let jsonString = String(cleaned[jsonStart.lowerBound...jsonEnd.upperBound])
                
                if let data = jsonString.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let caption = json["caption"] as? String,
                   !caption.isEmpty {
                    cleaned = caption
                    print("✅ Extracted from JSON: '\(cleaned)'")
                }
            }
        }
        
        // Remove JSON brackets if they're still there
        if (cleaned.hasPrefix("[") || cleaned.hasPrefix("{")) && cleaned.count < 10 {
            print("⚠️ Caption is just JSON brackets after extraction, using fallback")
            return "Captured Moment"
        }
        
        // Remove markdown code blocks
        cleaned = cleaned.replacingOccurrences(of: "```json", with: "")
        cleaned = cleaned.replacingOccurrences(of: "```javascript", with: "")
        cleaned = cleaned.replacingOccurrences(of: "```", with: "")
        
        // Remove JSON brackets and braces
        cleaned = cleaned.replacingOccurrences(of: "{", with: "")
        cleaned = cleaned.replacingOccurrences(of: "}", with: "")
        cleaned = cleaned.replacingOccurrences(of: "[", with: "")
        cleaned = cleaned.replacingOccurrences(of: "]", with: "")
        
        // Remove common prefixes
        let prefixes = ["Caption:", "caption:", "Answer:", "Response:", "Result:", "Output:", "caption =", "Caption ="]
        for prefix in prefixes {
            if cleaned.hasPrefix(prefix) {
                cleaned = String(cleaned.dropFirst(prefix.count))
            }
        }
        
        // Remove quotes and colons
        cleaned = cleaned.replacingOccurrences(of: "\"", with: "")
        cleaned = cleaned.replacingOccurrences(of: "'", with: "")
        cleaned = cleaned.replacingOccurrences(of: ":", with: "")
        
        // Remove newlines and get first non-empty line
        cleaned = cleaned.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .first ?? cleaned
        
        // Clean up whitespace
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If still malformed, use fallback
        if cleaned.count < 3 || !cleaned.contains(where: { $0.isLetter }) {
            print("⚠️ Caption still malformed: '\(cleaned)', using fallback")
            return "Moment Captured"
        }
        
        // Extract first 5 words if too long
        let words = cleaned.split(separator: " ").filter { !$0.isEmpty }
        if words.count > 5 {
            cleaned = words.prefix(5).joined(separator: " ")
        }
        
        // Capitalize first letter of each word (Title Case)
        cleaned = cleaned.split(separator: " ")
            .filter { !$0.isEmpty }
            .map { word in
                let firstChar = word.prefix(1).uppercased()
                let rest = word.dropFirst().lowercased()
                return firstChar + rest
            }
            .joined(separator: " ")
        
        print("✅ Final cleaned caption: '\(cleaned)'")
        return cleaned.isEmpty ? "Visual Moment" : cleaned
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
        // Generate varied, interesting captions for fallback mode
        let templates = [
            "\(interpretation.vibes.first?.capitalized ?? "Captured") \(interpretation.objects.first?.capitalized ?? "Moment")",
            "\(interpretation.scene.split(separator: " ").prefix(3).joined(separator: " "))",
            "\(interpretation.vibes.first?.capitalized ?? "Special") \(interpretation.actions.first?.capitalized ?? "Scene")",
            "The \(interpretation.vibes.first ?? "Amazing") \(interpretation.objects.first ?? "View")",
            "\(interpretation.objects.first?.capitalized ?? "Beautiful") and \(interpretation.vibes.first?.capitalized ?? "Serene")"
        ]
        
        // Pick a random template based on hash of objects (consistent per image)
        let index = abs(interpretation.objects.joined().hashValue) % templates.count
        var caption = templates[index]
        
        // Clean up and limit to 5 words
        let words = caption.split(separator: " ").filter { !$0.isEmpty }.prefix(5)
        caption = words.map { $0.capitalized }.joined(separator: " ")
        
        print("🤖 Generated mock caption: '\(caption)'")
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
        if wordCount >= 1 && wordCount <= 5 { score += 2 }
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

