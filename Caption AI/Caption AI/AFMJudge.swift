//
//  AFMJudge.swift
//  Caption Clash
//
//  Builds prompts and rubrics for AFM-powered caption judging
//  Markdown-formatted for clarity and structure
//

import Foundation

struct AFMJudge {
    
    // MARK: - Stage A: Image Interpretation Prompt
    
    static func buildInterpretationPrompt() -> String {
        """
        # Analyze Attached Image
        
        You are a precise visual analyzer. Examine the image and fill the ImageInterpretation structure:
        
        - **Objects**: List concrete nouns visible (e.g., "cat", "laptop", "tree")
        - **Scene**: Write one clear sentence describing the overall scene
        - **Actions**: List verbs for any actions/interactions happening
        - **Vibes**: Describe atmosphere in 1-3 words (e.g., "cozy", "energetic")
        - **AltText**: Write accessible alt text (1-2 sentences)
        - **SafetyFlag**: Choose one: "none", "contains_people", "contains_children", "contains_text", "contains_logos"
        
        Be concise and factual. Output only structured fields.
        """
    }
    
    // MARK: - Stage B: AI Caption Generation Prompt
    
    static func buildCaptionPrompt(interpretation: ImageInterpretation) -> String {
        let summary = interpretation.markdownSummary
        
        return """
        \(summary)
        
        # Task: Generate Caption
        
        Based on the image analysis above, create a clever, evocative caption.
        
        **Rules:**
        - Up to 5 words (1-5 words ideal)
        - Title Case (e.g., "Cozy Morning Vibes")
        - No emojis
        - Max 1 punctuation mark
        - Be creative but accurate to the image
        
        Output only the AICaption structure.
        """
    }
    
    // MARK: - Judge: Scoring Prompt with Rubric
    
    static func buildJudgmentPrompt(
        userCaption: String,
        aiCaption: String,
        interpretation: ImageInterpretation
    ) -> String {
        let summary = interpretation.markdownSummary
        let safeMode = interpretation.safetyFlag != .none
        
        let rubric = """
        ## Scoring Rubric (0-10)
        
        **0-3**: Off-topic, generic, or completely misses image content
        **4-6**: Partially relevant but bland, vague, or weak connection
        **7-8**: Strong alignment with image, specific and clear
        **9-10**: Evocative, precise, creative—captures essence perfectly
        
        ## Evaluation Categories
        - **Relevance**: Does it match the image content?
        - **Specificity**: Is it concrete or generic?
        - **Fluency**: Is it well-phrased?
        - **Originality**: Is it creative or cliché?
        """
        
        let safetyNote = safeMode ? """
        
        ⚠️ **Safety Note**: Image contains sensitive content. Keep tips generic and constructive.
        """ : ""
        
        return """
        \(summary)
        
        # Compare Captions
        
        **User Caption:** "\(userCaption)"
        **AI Caption:** "\(aiCaption)"
        
        \(rubric)
        
        # Task: Judge User Caption
        
        Score the **user's caption** (0-10) based on the rubric above.
        Provide 2-3 short, actionable tips for improvement.
        List 2-3 category names evaluated (e.g., ["Relevance", "Specificity"]).
        \(safetyNote)
        
        Output only the CaptionJudgment structure.
        """
    }
    
    // MARK: - Validation Helpers
    
    /// Validate caption format (1-5 words, basic cleanup)
    static func validateCaption(_ caption: String) -> (isValid: Bool, cleaned: String) {
        let cleaned = caption.trimmingCharacters(in: .whitespacesAndNewlines)
        let wordCount = cleaned.split(separator: " ").count
        let isValid = wordCount >= 1 && wordCount <= 5 && !cleaned.isEmpty
        return (isValid, cleaned)
    }
    
    /// Sanitize tips for safety-flagged content
    static func sanitizeTips(_ tips: [String], safetyFlag: ImageInterpretation.SafetyFlag) -> [String] {
        if safetyFlag == .none {
            return tips
        }
        // Generic fallback for sensitive content
        return tips.map { tip in
            if tip.lowercased().contains("person") || tip.lowercased().contains("face") {
                return "Focus on scene elements and atmosphere."
            }
            return tip
        }
    }
}

