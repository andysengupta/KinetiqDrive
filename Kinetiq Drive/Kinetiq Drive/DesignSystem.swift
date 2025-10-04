//
//  DesignSystem.swift
//  Ride IQ
//
//  Created by Assistant on 04.10.25.
//

import SwiftUI

enum DesignSystem {
    enum Colors {
        static let brandStart = Color(red: 1.00, green: 0.55, blue: 0.15)
        static let brandEnd = Color(red: 0.95, green: 0.20, blue: 0.45)
        static let pillBackground = Color.black.opacity(0.08)
        static let cardBackground = Color(.secondarySystemBackground)
        static let ringBackground = Color.white.opacity(0.15)
        static let stopBlue = Color.blue
        static let playOrange = Color.orange
        static let pauseGray = Color.gray
    }

    enum Gradients {
        static let background = LinearGradient(colors: [Colors.brandStart, Colors.brandEnd], startPoint: .topLeading, endPoint: .bottomTrailing)
        static func score(for value: Double) -> LinearGradient {
            let clamped = max(0, min(10, value)) / 10.0
            // Red → Yellow → Green
            let red = Color(red: 1.0, green: 0.3 + 0.4 * clamped, blue: 0.2)
            let green = Color(red: 0.2, green: 0.7 + 0.3 * clamped, blue: 0.3)
            return LinearGradient(colors: [red, green], startPoint: .leading, endPoint: .trailing)
        }
    }

    enum Spacing {
        static let s: CGFloat = 8
        static let m: CGFloat = 12
        static let l: CGFloat = 16
        static let xl: CGFloat = 24
    }

    enum Radius {
        static let card: CGFloat = 16
        static let pill: CGFloat = 22
    }
}

struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.card)
                    .fill(DesignSystem.Colors.cardBackground)
            )
    }
}

extension View {
    func cardBackground() -> some View { modifier(CardBackground()) }
}


