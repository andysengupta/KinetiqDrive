//
//  DesignSystem.swift
//  Caption Clash
//
//  Centralized design system following Apple HIG 2025
//  Defines colors, gradients, typography, spacing, and reusable components
//

import SwiftUI

// MARK: - Colors & Gradients

extension Color {
    static let accent = Color.blue
    static let accentSecondary = Color.mint
    
    static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
    static let cardBorder = Color(uiColor: .separator).opacity(0.5)
    
    static let successGreen = Color.green
    static let warningOrange = Color.orange
    static let errorRed = Color.red
}

struct Gradients {
    static let primary = LinearGradient(
        colors: [.accent, .accentSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let success = LinearGradient(
        colors: [.green, .mint],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let subtle = LinearGradient(
        colors: [Color.cardBackground, Color.cardBackground.opacity(0.8)],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Typography

struct Typography {
    static let largeTitle = Font.largeTitle.weight(.bold)
    static let title = Font.title.weight(.semibold)
    static let title2 = Font.title2.weight(.semibold)
    static let title3 = Font.title3.weight(.medium)
    static let headline = Font.headline
    static let body = Font.body
    static let callout = Font.callout
    static let caption = Font.caption
    static let caption2 = Font.caption2
}

// MARK: - Spacing & Sizing

struct Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

struct CornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
}

// MARK: - Reusable View Modifiers

struct CardModifier: ViewModifier {
    var backgroundColor: Color = .cardBackground
    
    func body(content: Content) -> some View {
        content
            .padding(Spacing.md)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .stroke(Color.cardBorder, lineWidth: 0.5)
            )
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(
                isEnabled ? Gradients.primary : Gradients.subtle
            )
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
            .opacity(isEnabled ? 1.0 : 0.6)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(Color.accent)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .stroke(Color.accent, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - View Extensions

extension View {
    func cardStyle(backgroundColor: Color = .cardBackground) -> some View {
        self.modifier(CardModifier(backgroundColor: backgroundColor))
    }
    
    func primaryButtonStyle(isEnabled: Bool = true) -> some View {
        self.buttonStyle(PrimaryButtonStyle(isEnabled: isEnabled))
    }
    
    func secondaryButtonStyle() -> some View {
        self.buttonStyle(SecondaryButtonStyle())
    }
}

// MARK: - SF Symbols Wrapper

struct SFSymbols {
    static let photoSelect = "photo.on.rectangle.angled"
    static let aiMagic = "wand.and.stars"
    static let textFormat = "textformat.abc"
    static let badge = "rosette"
    static let trophy = "trophy.fill"
    static let gameController = "gamecontroller.fill"
    static let sparkles = "sparkles"
    static let chartBar = "chart.bar.fill"
    static let clock = "clock.fill"
    static let gear = "gearshape.fill"
    static let checkmark = "checkmark.circle.fill"
    static let xmark = "xmark.circle.fill"
    static let star = "star.fill"
    static let starHalf = "star.leadinghalf.filled"
    static let flame = "flame.fill"
    static let shield = "shield.fill"
    static let eye = "eye.fill"
    static let brain = "brain.head.profile"
    static let exclamation = "exclamationmark.triangle.fill"
    static let share = "square.and.arrow.up"
    static let trash = "trash.fill"
    static let info = "info.circle.fill"
}

// MARK: - Empty State View

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionLabel: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(Gradients.primary)
                .symbolRenderingMode(.hierarchical)
            
            Text(title)
                .font(Typography.title2)
                .foregroundStyle(.primary)
            
            Text(message)
                .font(Typography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
            
            if let actionLabel = actionLabel, let action = action {
                Button(action: action) {
                    Text(actionLabel)
                        .frame(maxWidth: .infinity)
                }
                .primaryButtonStyle()
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.sm)
            }
        }
        .padding(Spacing.xl)
    }
}

// MARK: - Loading View

struct LoadingStateView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.accent)
            
            Text(message)
                .font(Typography.body)
                .foregroundStyle(.secondary)
            
            Image(systemName: SFSymbols.sparkles)
                .font(.title2)
                .foregroundStyle(Gradients.primary)
                .symbolEffect(.pulse)
        }
        .padding(Spacing.xl)
    }
}

