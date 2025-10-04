//
//  PlayView.swift
//  Caption Clash
//
//  Main gameplay view: Image selection → Caption input → AI processing → Score reveal
//

import SwiftUI
import PhotosUI
import SwiftData

struct PlayView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var afmService: AFMService
    @EnvironmentObject private var gameEngine: GameEngine
    @EnvironmentObject private var photoPickerService: PhotoPickerService
    
    // UI State
    @State private var gameState: GameState = .selectImage
    @State private var userCaption: String = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isProcessing = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    // Game Data
    @State private var interpretation: ImageInterpretation?
    @State private var aiCaption: AICaption?
    @State private var judgment: CaptionJudgment?
    @State private var showConfetti = false
    
    // Character limit
    private let maxCaptionLength = 50
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Header
                    headerView
                    
                    // Main content based on state
                    switch gameState {
                    case .selectImage:
                        imageSelectionView
                    case .enterCaption:
                        captionInputView
                    case .processing:
                        processingView
                    case .showResults:
                        // Navigate to ScoreView
                        EmptyView()
                    }
                }
                .padding(Spacing.md)
            }
            .navigationTitle("Caption Clash")
            .navigationBarTitleDisplayMode(.large)
        }
        .confetti(isActive: showConfetti)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .navigationDestination(isPresented: .init(
            get: { gameState == .showResults },
            set: { if !$0 { resetGame() } }
        )) {
            if let judgment = judgment, 
               let aiCaption = aiCaption,
               let interpretation = interpretation,
               let image = photoPickerService.selectedImage {
                ScoreView(
                    image: image,
                    userCaption: userCaption,
                    aiCaption: aiCaption.caption,
                    judgment: judgment,
                    interpretation: interpretation,
                    onPlayAgain: { resetGame() }
                )
            }
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(spacing: Spacing.sm) {
            HStack {
                Image(systemName: SFSymbols.flame)
                    .foregroundStyle(.orange)
                Text("Streak: \(gameEngine.currentStreak)")
                    .font(Typography.headline)
                
                Spacer()
                
                if !afmService.isAvailable {
                    Label("Manual Mode", systemImage: SFSymbols.exclamation)
                        .font(Typography.caption)
                        .foregroundStyle(.orange)
                }
            }
            .padding(Spacing.md)
            .cardStyle()
        }
    }
    
    // MARK: - Image Selection
    
    private var imageSelectionView: some View {
        VStack(spacing: Spacing.lg) {
            if let image = photoPickerService.selectedImage {
                // Show selected image
                VStack(spacing: Spacing.md) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
                        .shadow(radius: 5)
                    
                    Button {
                        photoPickerService.clearSelection()
                        Haptics.selectionChanged()
                    } label: {
                        Label("Change Photo", systemImage: "arrow.triangle.2.circlepath")
                    }
                    .secondaryButtonStyle()
                    
                    Button {
                        proceedToCaption()
                    } label: {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                    }
                    .primaryButtonStyle()
                }
            } else {
                // Empty state
                EmptyStateView(
                    icon: SFSymbols.photoSelect,
                    title: "Get Started",
                    message: "Pick a photo and clash captions with AI!",
                    actionLabel: "Select Photo",
                    action: {
                        photoPickerService.presentPicker()
                        Haptics.selectionChanged()
                    }
                )
            }
        }
        .photosPicker(
            isPresented: $photoPickerService.isPickerPresented,
            selection: $selectedPhoto,
            matching: .images
        )
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                await photoPickerService.handleSelection(newItem)
            }
        }
    }
    
    // MARK: - Caption Input
    
    private var captionInputView: some View {
        VStack(spacing: Spacing.lg) {
            // Image preview
            if let image = photoPickerService.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                    .shadow(radius: 3)
            }
            
            // Instructions
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Label("Write Your Caption", systemImage: SFSymbols.textFormat)
                    .font(Typography.title3)
                
                Text("Enter 3-5 words that capture this image")
                    .font(Typography.callout)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.md)
            .cardStyle()
            
            // Text field
            VStack(spacing: Spacing.sm) {
                TextField("Your caption...", text: $userCaption, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2)
                    .font(Typography.title3)
                    .onChange(of: userCaption) { _, newValue in
                        if newValue.count > maxCaptionLength {
                            userCaption = String(newValue.prefix(maxCaptionLength))
                            Haptics.warning()
                        }
                    }
                
                HStack {
                    Text("\(userCaption.split(separator: " ").count) words")
                        .font(Typography.caption)
                        .foregroundStyle(captionWordCount >= 3 && captionWordCount <= 5 ? .green : .secondary)
                    
                    Spacer()
                    
                    Text("\(userCaption.count)/\(maxCaptionLength)")
                        .font(Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(Spacing.md)
            .cardStyle()
            
            // Actions
            HStack(spacing: Spacing.md) {
                Button {
                    gameState = .selectImage
                    userCaption = ""
                    Haptics.selectionChanged()
                } label: {
                    Text("Back")
                        .frame(maxWidth: .infinity)
                }
                .secondaryButtonStyle()
                
                Button {
                    submitCaption()
                } label: {
                    Text("Clash! ⚔️")
                        .frame(maxWidth: .infinity)
                }
                .primaryButtonStyle(isEnabled: isValidCaption)
                .disabled(!isValidCaption)
            }
        }
    }
    
    // MARK: - Processing
    
    private var processingView: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()
            
            LoadingStateView(message: "AI is analyzing...")
            
            VStack(spacing: Spacing.sm) {
                Text("✨ Interpreting image...")
                    .font(Typography.callout)
                    .foregroundStyle(.secondary)
                Text("🤖 Generating AI caption...")
                    .font(Typography.callout)
                    .foregroundStyle(.secondary)
                Text("⚖️ Judging captions...")
                    .font(Typography.callout)
                    .foregroundStyle(.secondary)
            }
            .padding(Spacing.lg)
            
            Spacer()
        }
    }
    
    // MARK: - Helpers
    
    private var captionWordCount: Int {
        userCaption.split(separator: " ").count
    }
    
    private var isValidCaption: Bool {
        let count = captionWordCount
        return count >= 3 && count <= 5 && !userCaption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func proceedToCaption() {
        gameState = .enterCaption
        Haptics.selectionChanged()
    }
    
    private func submitCaption() {
        guard isValidCaption else { return }
        Haptics.selectionChanged()
        gameState = .processing
        
        Task {
            await processGameRound()
        }
    }
    
    private func processGameRound() async {
        guard let image = photoPickerService.selectedImage else {
            showErrorMessage("No image selected")
            return
        }
        
        do {
            // Stage A: Interpret image
            interpretation = try await afmService.interpretImage(image)
            
            guard let interp = interpretation else {
                showErrorMessage("Failed to interpret image")
                return
            }
            
            // Stage B: Generate AI caption
            aiCaption = try await afmService.generateCaption(from: interp)
            
            guard let aiCap = aiCaption else {
                showErrorMessage("Failed to generate AI caption")
                return
            }
            
            // Judge: Score captions
            judgment = try await afmService.judgeCaption(
                userCaption: userCaption,
                aiCaption: aiCap.caption,
                interpretation: interp
            )
            
            guard let judg = judgment else {
                showErrorMessage("Failed to judge captions")
                return
            }
            
            // Save round
            await saveRound(judgment: judg, interpretation: interp, aiCaption: aiCap, image: image)
            
            // Show confetti for high scores
            if judg.score >= 9 {
                showConfetti = true
                Haptics.success()
            } else if judg.score >= 8 {
                Haptics.success()
            }
            
            // Navigate to results
            gameState = .showResults
            
        } catch {
            showErrorMessage(error.localizedDescription)
        }
    }
    
    private func saveRound(
        judgment: CaptionJudgment,
        interpretation: ImageInterpretation,
        aiCaption: AICaption,
        image: UIImage
    ) async {
        let thumbnailData = ImageUtils.createThumbnail(image)
        let didUserWin = gameEngine.determineWinner(score: judgment.score)
        
        let round = RoundRecord(
            thumbnailData: thumbnailData,
            userCaption: userCaption,
            aiCaption: aiCaption.caption,
            score: judgment.score,
            tips: judgment.shortTips,
            categories: judgment.categories,
            didUserWin: didUserWin,
            safetyFlag: interpretation.safetyFlag.rawValue
        )
        
        modelContext.insert(round)
        
        do {
            try modelContext.save()
            
            // Update game state
            gameEngine.recordPlay()
            
            // Check badge unlocks
            let descriptor = FetchDescriptor<RoundRecord>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            let allRounds = try modelContext.fetch(descriptor)
            await gameEngine.checkBadgeUnlocks(context: modelContext, rounds: allRounds)
            
        } catch {
            print("Failed to save round: \(error)")
        }
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
        gameState = .enterCaption
        Haptics.error()
    }
    
    private func resetGame() {
        gameState = .selectImage
        userCaption = ""
        photoPickerService.clearSelection()
        interpretation = nil
        aiCaption = nil
        judgment = nil
        showConfetti = false
    }
}

// MARK: - Game State

enum GameState {
    case selectImage
    case enterCaption
    case processing
    case showResults
}

#Preview {
    NavigationStack {
        PlayView()
    }
    .environmentObject(AFMService())
    .environmentObject(GameEngine())
    .environmentObject(PhotoPickerService())
    .modelContainer(for: [RoundRecord.self, BadgeState.self], inMemory: true)
}

