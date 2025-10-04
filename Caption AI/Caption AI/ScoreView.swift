//
//  ScoreView.swift
//  Caption Clash
//
//  Displays round results: user vs AI caption, score with gauge, tips, share options
//

import SwiftUI

struct ScoreView: View {
    let image: UIImage
    let userCaption: String
    let aiCaption: String
    let judgment: CaptionJudgment
    let interpretation: ImageInterpretation
    let onPlayAgain: () -> Void
    
    @EnvironmentObject private var gameEngine: GameEngine
    @State private var showShareSheet = false
    @State private var shareImage: UIImage?
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Result header
                resultHeaderView
                
                // Image
                imageView
                
                // Captions comparison
                captionsView
                
                // Score gauge
                scoreGaugeView
                
                // Tips
                tipsView
                
                // Actions
                actionsView
            }
            .padding(Spacing.md)
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            if let shareImage = shareImage {
                let captionText = "Caption Clash: \"\(winningCaption)\" - Score: \(judgment.score)/10 🏆"
                ShareSheet(items: [shareImage, captionText])
            }
        }
        .onAppear {
            // Pre-render share image for better performance
            Task {
                await prepareShareImageInBackground()
            }
        }
    }
    
    // MARK: - Result Header
    
    private var resultHeaderView: some View {
        VStack(spacing: Spacing.md) {
            Text(gameEngine.getScoreEmoji(for: judgment.score))
                .font(.system(size: 60))
            
            Text(gameEngine.getScoreMessage(for: judgment.score))
                .font(Typography.title2)
                .multilineTextAlignment(.center)
            
            if didUserWin {
                Label("You Win!", systemImage: SFSymbols.trophy)
                    .font(Typography.headline)
                    .foregroundStyle(Gradients.success)
            } else {
                Label("AI Wins", systemImage: SFSymbols.brain)
                    .font(Typography.headline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity)
        .cardStyle(backgroundColor: didUserWin ? .green.opacity(0.1) : .cardBackground)
    }
    
    // MARK: - Image
    
    private var imageView: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(maxHeight: 250)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
            .shadow(radius: 5)
    }
    
    // MARK: - Captions
    
    private var captionsView: some View {
        VStack(spacing: Spacing.md) {
            // User caption
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Label("Your Caption", systemImage: "person.fill")
                        .font(Typography.headline)
                    Spacer()
                    if didUserWin {
                        Image(systemName: SFSymbols.checkmark)
                            .foregroundStyle(.green)
                    }
                }
                
                Text("\"\(userCaption)\"")
                    .font(Typography.title3)
                    .italic()
            }
            .padding(Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardStyle(backgroundColor: didUserWin ? .green.opacity(0.1) : .cardBackground)
            
            // VS Divider
            HStack {
                Rectangle()
                    .fill(.secondary.opacity(0.3))
                    .frame(height: 1)
                Text("vs")
                    .font(Typography.caption)
                    .foregroundStyle(.secondary)
                Rectangle()
                    .fill(.secondary.opacity(0.3))
                    .frame(height: 1)
            }
            
            // AI caption
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Label("AI Caption", systemImage: SFSymbols.aiMagic)
                        .font(Typography.headline)
                    Spacer()
                    if !didUserWin {
                        Image(systemName: SFSymbols.checkmark)
                            .foregroundStyle(.blue)
                    }
                }
                
                Text("\"\(aiCaption)\"")
                    .font(Typography.title3)
                    .italic()
            }
            .padding(Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardStyle(backgroundColor: !didUserWin ? .blue.opacity(0.1) : .cardBackground)
        }
    }
    
    // MARK: - Score Gauge
    
    private var scoreGaugeView: some View {
        VStack(spacing: Spacing.md) {
            Text("Your Score")
                .font(Typography.headline)
            
            Gauge(value: Double(judgment.score), in: 0...10) {
                Text("\(judgment.score)")
            } currentValueLabel: {
                Text("\(judgment.score)")
                    .font(.system(size: 48, weight: .bold))
            } minimumValueLabel: {
                Text("0")
                    .font(Typography.caption2)
            } maximumValueLabel: {
                Text("10")
                    .font(Typography.caption2)
            }
            .gaugeStyle(.accessoryCircular)
            .tint(scoreGradient)
            .scaleEffect(1.5)
            
            // Categories
            HStack(spacing: Spacing.sm) {
                ForEach(judgment.categories, id: \.self) { category in
                    Text(category)
                        .font(Typography.caption)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xs)
                        .background(.secondary.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
    
    private var scoreGradient: Gradient {
        if judgment.score >= 9 {
            return Gradient(colors: [.green, .mint])
        } else if judgment.score >= 7 {
            return Gradient(colors: [.blue, .cyan])
        } else if judgment.score >= 5 {
            return Gradient(colors: [.orange, .yellow])
        } else {
            return Gradient(colors: [.red, .orange])
        }
    }
    
    // MARK: - Tips
    
    private var tipsView: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Label("Tips for Improvement", systemImage: "lightbulb.fill")
                .font(Typography.headline)
            
            ForEach(Array(judgment.shortTips.enumerated()), id: \.offset) { index, tip in
                HStack(alignment: .top, spacing: Spacing.sm) {
                    Text("\(index + 1).")
                        .font(Typography.callout)
                        .foregroundStyle(.secondary)
                    Text(tip)
                        .font(Typography.callout)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.md)
        .cardStyle()
    }
    
    // MARK: - Actions
    
    private var actionsView: some View {
        VStack(spacing: Spacing.md) {
            Button {
                prepareShare()
                Haptics.selectionChanged()
            } label: {
                Label("Share Result", systemImage: SFSymbols.share)
                    .frame(maxWidth: .infinity)
            }
            .secondaryButtonStyle()
            
            Button {
                onPlayAgain()
                Haptics.selectionChanged()
            } label: {
                Text("Play Again")
                    .frame(maxWidth: .infinity)
            }
            .primaryButtonStyle()
        }
    }
    
    // MARK: - Helpers
    
    private var didUserWin: Bool {
        judgment.winner == .user
    }
    
    private var winningCaption: String {
        didUserWin ? userCaption : aiCaption
    }
    
    private func prepareShare() {
        // Show share sheet immediately (image may already be pre-rendered)
        if shareImage == nil {
            // Render on demand if not pre-rendered
            let renderer = ImageRenderer(content: shareableView)
            renderer.scale = UIScreen.main.scale * 2.0
            shareImage = renderer.uiImage ?? image
        }
        showShareSheet = true
    }
    
    private func prepareShareImageInBackground() async {
        // Pre-render the shareable image in background for smooth sharing
        await MainActor.run {
            let renderer = ImageRenderer(content: shareableView)
            renderer.scale = UIScreen.main.scale * 2.0
            shareImage = renderer.uiImage ?? image
        }
    }
    
    private var shareableView: some View {
        VStack(spacing: Spacing.md) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: 400, height: 400)
            
            VStack(spacing: Spacing.sm) {
                Text("\"\(winningCaption)\"")
                    .font(.title2.weight(.semibold))
                    .italic()
                
                HStack {
                    Text("Score: \(judgment.score)/10")
                        .font(.headline)
                    Image(systemName: SFSymbols.trophy)
                }
                .foregroundStyle(Gradients.primary)
                
                Text("Caption Clash")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(Spacing.lg)
        }
        .padding(Spacing.lg)
        .background(.white)
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        
        // Exclude some activities for better UX
        controller.excludedActivityTypes = [
            .assignToContact,
            .addToReadingList,
            .openInIBooks
        ]
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        ScoreView(
            image: UIImage(systemName: "photo")!,
            userCaption: "Cozy Morning Vibes",
            aiCaption: "Peaceful Dawn Light",
            judgment: CaptionJudgment(
                score: 9,
                shortTips: [
                    "Great use of atmosphere!",
                    "Consider more specific objects",
                    "Strong emotional resonance"
                ],
                categories: ["Relevance", "Creativity", "Specificity"]
            ),
            interpretation: ImageInterpretation(
                objects: ["coffee", "laptop", "window"],
                scene: "A cozy workspace by a window",
                actions: ["working", "sipping"],
                vibes: ["peaceful", "morning"],
                altText: "A laptop and coffee cup on a desk by a window",
                safetyFlag: .none
            ),
            onPlayAgain: {}
        )
    }
    .environmentObject(GameEngine())
}

