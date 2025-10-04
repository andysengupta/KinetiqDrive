//
//  HistoryView.swift
//  Caption Clash
//
//  SwiftData-backed list of past rounds with thumbnails and details
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RoundRecord.timestamp, order: .reverse) private var rounds: [RoundRecord]
    @EnvironmentObject private var gameEngine: GameEngine
    
    @State private var selectedRound: RoundRecord?
    
    var body: some View {
        Group {
            if rounds.isEmpty {
                emptyStateView
            } else {
                contentView
            }
        }
        .navigationTitle("History")
        .sheet(item: $selectedRound) { round in
            NavigationStack {
                RoundDetailView(round: round)
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        EmptyStateView(
            icon: SFSymbols.clock,
            title: "No History Yet",
            message: "Your past caption clashes will appear here"
        )
    }
    
    // MARK: - Content
    
    private var contentView: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Stats card
                statsCardView
                
                // Rounds list
                LazyVStack(spacing: Spacing.md) {
                    ForEach(rounds) { round in
                        RoundRowView(round: round)
                            .onTapGesture {
                                selectedRound = round
                                Haptics.selectionChanged()
                            }
                    }
                }
            }
            .padding(Spacing.md)
        }
    }
    
    // MARK: - Stats Card
    
    private var statsCardView: some View {
        let stats = gameEngine.calculateStats(from: rounds)
        
        return VStack(spacing: Spacing.md) {
            HStack {
                Image(systemName: SFSymbols.chartBar)
                    .foregroundStyle(Gradients.primary)
                Text("Your Stats")
                    .font(Typography.headline)
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Spacing.md) {
                StatItem(label: "Rounds", value: "\(stats.totalRounds)")
                StatItem(label: "Avg Score", value: String(format: "%.1f", stats.averageScore))
                StatItem(label: "Best", value: "\(stats.highestScore)")
                StatItem(label: "Perfect", value: "\(stats.perfectScores)")
                StatItem(label: "Streak", value: "\(stats.currentStreak)")
                StatItem(label: "Win Rate", value: "\(Int(stats.winRate * 100))%")
            }
        }
        .padding(Spacing.md)
        .cardStyle()
    }
}

// MARK: - Round Row

struct RoundRowView: View {
    let round: RoundRecord
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Thumbnail
            if let thumbnail = round.thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
            } else {
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .fill(.secondary.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: SFSymbols.photoSelect)
                            .foregroundStyle(.secondary)
                    }
            }
            
            // Info
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("\"\(round.userCaption)\"")
                    .font(Typography.callout.weight(.medium))
                    .lineLimit(1)
                
                Text(round.timestamp, style: .relative)
                    .font(Typography.caption2)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: Spacing.xs) {
                    if round.didUserWin {
                        Label("Won", systemImage: SFSymbols.trophy)
                            .font(Typography.caption2)
                            .foregroundStyle(.green)
                    } else {
                        Label("Lost", systemImage: SFSymbols.brain)
                            .font(Typography.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Score
            VStack {
                Text("\(round.score)")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(scoreColor(round.score))
                Text("/ 10")
                    .font(Typography.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(Spacing.md)
        .cardStyle()
    }
    
    private func scoreColor(_ score: Int) -> Color {
        if score >= 8 { return .green }
        else if score >= 6 { return .blue }
        else if score >= 4 { return .orange }
        else { return .red }
    }
}

// MARK: - Stat Item

struct StatItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text(value)
                .font(Typography.title3.weight(.bold))
                .foregroundStyle(Gradients.primary)
            Text(label)
                .font(Typography.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Round Detail View

struct RoundDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let round: RoundRecord
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Image
                if let thumbnail = round.thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
                }
                
                // Captions
                VStack(spacing: Spacing.md) {
                    captionCard(
                        title: "Your Caption",
                        caption: round.userCaption,
                        won: round.didUserWin
                    )
                    
                    captionCard(
                        title: "AI Caption",
                        caption: round.aiCaption,
                        won: !round.didUserWin
                    )
                }
                
                // Score
                VStack(spacing: Spacing.sm) {
                    Text("Score: \(round.score)/10")
                        .font(Typography.title)
                    
                    HStack {
                        ForEach(round.categories, id: \.self) { category in
                            Text(category)
                                .font(Typography.caption)
                                .padding(.horizontal, Spacing.sm)
                                .padding(.vertical, Spacing.xs)
                                .background(.secondary.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(Spacing.md)
                .cardStyle()
                
                // Tips
                if !round.tips.isEmpty {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Tips")
                            .font(Typography.headline)
                        
                        ForEach(Array(round.tips.enumerated()), id: \.offset) { index, tip in
                            HStack(alignment: .top, spacing: Spacing.sm) {
                                Text("\(index + 1).")
                                    .foregroundStyle(.secondary)
                                Text(tip)
                            }
                            .font(Typography.callout)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Spacing.md)
                    .cardStyle()
                }
            }
            .padding(Spacing.md)
        }
        .navigationTitle("Round Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
    
    private func captionCard(title: String, caption: String, won: Bool) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text(title)
                    .font(Typography.headline)
                Spacer()
                if won {
                    Image(systemName: SFSymbols.trophy)
                        .foregroundStyle(.green)
                }
            }
            
            Text("\"\(caption)\"")
                .font(Typography.title3)
                .italic()
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle(backgroundColor: won ? .green.opacity(0.1) : .cardBackground)
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
    .environmentObject(GameEngine())
    .modelContainer(for: [RoundRecord.self, BadgeState.self], inMemory: true)
}

