//
//  Haptics.swift
//  Caption Clash
//
//  Haptic feedback wrapper for polished interactions
//

import UIKit

struct Haptics {
    
    // MARK: - Feedback Generators
    
    private static let impact = UIImpactFeedbackGenerator(style: .medium)
    private static let notification = UINotificationFeedbackGenerator()
    private static let selection = UISelectionFeedbackGenerator()
    
    // MARK: - Public Interface
    
    /// Light tap for selections, button presses
    static func selectionChanged() {
        selection.selectionChanged()
    }
    
    /// Success feedback (e.g., high score achieved)
    static func success() {
        notification.notificationOccurred(.success)
    }
    
    /// Warning feedback (e.g., caption too long)
    static func warning() {
        notification.notificationOccurred(.warning)
    }
    
    /// Error feedback (e.g., AI failed)
    static func error() {
        notification.notificationOccurred(.error)
    }
    
    /// Impact feedback for significant actions
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    /// Heavy impact for major achievements (badges, perfect scores)
    static func heavyImpact() {
        impact(style: .heavy)
    }
    
    // MARK: - Preparation (Optional Performance Optimization)
    
    static func prepare() {
        impact.prepare()
        notification.prepare()
        selection.prepare()
    }
}

