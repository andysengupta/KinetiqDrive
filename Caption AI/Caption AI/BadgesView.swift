//
//  BadgesView.swift
//  Caption Clash
//
//  Grid of badges with progress indicators and unlock animations
//

import SwiftUI
import SwiftData

struct BadgesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var badgeStates: [BadgeState]
    @EnvironmentObject private var gameEngine: GameEngine
    
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: Spacing.md)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Header
                headerView
                
                // Badge grid
                LazyVGrid(columns: columns, spacing: Spacing.md) {
                    ForEach(Badge.allCases) { badge in
                        BadgeCardView(
                            badge: badge,
                            state: badgeState(for: badge)
                        )
                        .onAppear {
                            if badgeState(for: badge).isNew {
                                markBadgeAsSeen(badge)
                            }
                        }
                    }
                }
            }
            .padding(Spacing.md)
        }
        .navigationTitle("Badges")
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        let unlockedCount = badgeStates.filter { $0.isUnlocked }.count
        let totalCount = Badge.allCases.count
        
        return VStack(spacing: Spacing.md) {
            HStack {
                Image(systemName: SFSymbols.badge)
                    .font(.title)
                    .foregroundStyle(Gradients.primary)
                
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Achievements")
                        .font(Typography.headline)
                    Text("\(unlockedCount) of \(totalCount) unlocked")
                        .font(Typography.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            ProgressView(value: Double(unlockedCount), total: Double(totalCount))
                .tint(.accent)
        }
        .padding(Spacing.md)
        .cardStyle()
    }
    
    // MARK: - Helpers
    
    private func badgeState(for badge: Badge) -> BadgeState {
        if let state = badgeStates.first(where: { $0.id == badge.rawValue }) {
            return state
        }
        // Return default state if not found
        return BadgeState(id: badge.rawValue)
    }
    
    private func markBadgeAsSeen(_ badge: Badge) {
        if let state = badgeStates.first(where: { $0.id == badge.rawValue }) {
            state.isNew = false
            gameEngine.newBadgesCount = max(0, gameEngine.newBadgesCount - 1)
        }
    }
}

// MARK: - Badge Card

struct BadgeCardView: View {
    let badge: Badge
    let state: BadgeState
    
    @State private var showDetail = false
    
    var body: some View {
        Button {
            showDetail = true
            Haptics.selectionChanged()
        } label: {
            VStack(spacing: Spacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(state.isUnlocked ? AnyShapeStyle(gradient) : AnyShapeStyle(Color.secondary.opacity(0.2)))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: badge.icon)
                        .font(.system(size: 36))
                        .foregroundStyle(state.isUnlocked ? .white : .secondary)
                        .symbolEffect(.bounce, value: state.isNew)
                    
                    if state.isNew {
                        Circle()
                            .fill(.red)
                            .frame(width: 12, height: 12)
                            .offset(x: 30, y: -30)
                    }
                }
                
                // Name
                Text(badge.name)
                    .font(Typography.callout.weight(.semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                // Lock status
                if !state.isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(Spacing.md)
            .frame(maxWidth: .infinity)
            .cardStyle()
            .opacity(state.isUnlocked ? 1.0 : 0.6)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDetail) {
            BadgeDetailView(badge: badge, state: state)
                .presentationDetents([.medium])
        }
    }
    
    private var gradient: LinearGradient {
        let colors = badge.gradient.compactMap { colorName -> Color? in
            switch colorName {
            case "yellow": return .yellow
            case "orange": return .orange
            case "red": return .red
            case "pink": return .pink
            case "purple": return .purple
            case "blue": return .blue
            case "cyan": return .cyan
            case "teal": return .teal
            case "green": return .green
            case "gray": return .gray
            case "black": return .black
            case "gold": return .yellow
            default: return nil
            }
        }
        return LinearGradient(
            colors: colors.isEmpty ? [.blue] : colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Badge Detail

struct BadgeDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let badge: Badge
    let state: BadgeState
    
    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.xl) {
                Spacer()
                
                // Large icon
                ZStack {
                    Circle()
                        .fill(state.isUnlocked ? AnyShapeStyle(gradient) : AnyShapeStyle(Color.secondary.opacity(0.2)))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: badge.icon)
                        .font(.system(size: 60))
                        .foregroundStyle(state.isUnlocked ? .white : .secondary)
                }
                .padding(Spacing.lg)
                
                // Name
                Text(badge.name)
                    .font(Typography.largeTitle)
                
                // Description
                Text(badge.description)
                    .font(Typography.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
                
                // Status
                if state.isUnlocked, let date = state.unlockedDate {
                    VStack(spacing: Spacing.xs) {
                        Image(systemName: SFSymbols.checkmark)
                            .foregroundStyle(.green)
                        Text("Unlocked \(date, style: .date)")
                            .font(Typography.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, Spacing.md)
                } else {
                    Label("Locked", systemImage: "lock.fill")
                        .font(Typography.callout)
                        .foregroundStyle(.secondary)
                        .padding(.top, Spacing.md)
                }
                
                Spacer()
            }
            .padding(Spacing.lg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var gradient: LinearGradient {
        let colors = badge.gradient.compactMap { colorName -> Color? in
            switch colorName {
            case "yellow": return .yellow
            case "orange": return .orange
            case "red": return .red
            case "pink": return .pink
            case "purple": return .purple
            case "blue": return .blue
            case "cyan": return .cyan
            case "teal": return .teal
            case "green": return .green
            case "gray": return .gray
            case "black": return .black
            case "gold": return .yellow
            default: return nil
            }
        }
        return LinearGradient(
            colors: colors.isEmpty ? [.blue] : colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

#Preview {
    NavigationStack {
        BadgesView()
    }
    .environmentObject(GameEngine())
    .modelContainer(for: [RoundRecord.self, BadgeState.self], inMemory: true)
}

