//
//  DesignSystem.swift
//  Ride IQ
//
//  Created by Assistant on 04.10.25.
//

import SwiftUI

enum DesignSystem {
    enum Colors {
        // Vibrant brand theme (orange → pink → magenta)
        static let brandA = Color(red: 1.00, green: 0.45, blue: 0.10)
        static let brandB = Color(red: 0.98, green: 0.20, blue: 0.55)
        static let brandC = Color(red: 0.77, green: 0.25, blue: 0.90)

        static let pillBackground = Color.white.opacity(0.10)
        static let glassFill = Color.white.opacity(0.14)
        static let glassStroke = Color.white.opacity(0.25)
        static let ringBackground = Color.white.opacity(0.15)
        static let stopBlue = Color(red: 0.10, green: 0.55, blue: 1.0)
        static let playOrange = Color(red: 1.00, green: 0.50, blue: 0.18)
        static let pauseGray = Color(white: 0.45)
    }

    enum Gradients {
        static let background = LinearGradient(colors: [Colors.brandA, Colors.brandB, Colors.brandC], startPoint: .topLeading, endPoint: .bottomTrailing)
        static func glow() -> LinearGradient { LinearGradient(colors: [Colors.brandB, .white.opacity(0.9)], startPoint: .top, endPoint: .bottom) }
        static func score(for value: Double) -> LinearGradient {
            let clamped = max(0, min(10, value)) / 10.0
            let start = Color(red: 1.0, green: 0.35 + 0.45 * clamped, blue: 0.22)
            let end = Color(red: 0.25, green: 0.85 * clamped + 0.15, blue: 0.35)
            return LinearGradient(colors: [start, end], startPoint: .leading, endPoint: .trailing)
        }
    }

    enum Spacing {
        static let s: CGFloat = 8
        static let m: CGFloat = 12
        static let l: CGFloat = 16
        static let xl: CGFloat = 24
    }

    enum Radius {
        static let card: CGFloat = 18
        static let pill: CGFloat = 22
    }
}

struct GlassBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.card)
                    .fill(DesignSystem.Colors.glassFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.Radius.card)
                            .stroke(DesignSystem.Colors.glassStroke, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.18), radius: 18, x: 0, y: 10)
            )
    }
}

extension View {
    func glassCard() -> some View { modifier(GlassBackground()) }
}


