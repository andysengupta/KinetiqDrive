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
    
    // Background processing
    @State private var isPreprocessing = false
    @State private var preprocessTask: Task<Void, Never>?
    
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
                        startBackgroundProcessing()
                    } label: {
                        HStack {
                            Text("Continue")
                            if isPreprocessing {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .tint(.white)
                            }
                        }
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
            
            // Enhanced Caption Input Card
            VStack(spacing: Spacing.lg) {
                // Header
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack {
                        Image(systemName: "sparkles")
                            .font(.title2)
                            .foregroundStyle(Gradients.primary)
                        Text("Your Creative Caption")
                            .font(Typography.title2.weight(.bold))
                        Spacer()
                    }
                    
                    Text("Write 3-5 words that capture the essence of this moment")
                        .font(Typography.callout)
                        .foregroundStyle(.secondary)
                }
                
                // Large, inviting text input
                VStack(spacing: Spacing.xs) {
                    ZStack(alignment: .topLeading) {
                        // Background with gradient border effect
                        RoundedRectangle(cornerRadius: CornerRadius.lg)
                            .fill(Color.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: CornerRadius.lg)
                                    .stroke(
                                        userCaption.isEmpty ? Color.gray.opacity(0.3) : 
                                        (isValidCaption ? Color.green : Color.blue),
                                        lineWidth: 2
                                    )
                            )
                        
                        // Text editor
                        TextField("Type your caption here...", text: $userCaption, axis: .vertical)
                            .textFieldStyle(.plain)
                            .font(.system(size: 22, weight: .medium, design: .rounded))
                            .lineLimit(3...5)
                            .padding(Spacing.md)
                            .onChange(of: userCaption) { _, newValue in
                                if newValue.count > maxCaptionLength {
                                    userCaption = String(newValue.prefix(maxCaptionLength))
                                    Haptics.warning()
                                }
                            }
                    }
                    .frame(minHeight: 100)
                    
                    // Word count indicators
                    HStack {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: captionWordCount >= 3 && captionWordCount <= 5 ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                .foregroundStyle(captionWordCount >= 3 && captionWordCount <= 5 ? .green : .orange)
                            Text("\(captionWordCount) words")
                                .font(Typography.callout.weight(.semibold))
                                .foregroundStyle(captionWordCount >= 3 && captionWordCount <= 5 ? .green : .orange)
                        }
                        
                        Spacer()
                        
                        Text("\(userCaption.count)/\(maxCaptionLength)")
                            .font(Typography.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, Spacing.xs)
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(Spacing.lg)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl))
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
            
            // Actions
            VStack(spacing: Spacing.sm) {
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
                
                // Helpful hint when button is disabled
                if !isValidCaption && !userCaption.isEmpty {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.orange)
                            .font(.caption)
                        Text("Write 3-5 words to clash!")
                            .font(Typography.caption)
                            .foregroundStyle(.orange)
                    }
                    .transition(.opacity.combined(with: .scale))
                }
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
    
    private func startBackgroundProcessing() {
        guard let image = photoPickerService.selectedImage else { return }
        
        // Cancel any existing task
        preprocessTask?.cancel()
        
        // Start background AI processing
        isPreprocessing = true
        preprocessTask = Task {
            do {
                // Stage A: Interpret image in background
                interpretation = try await afmService.interpretImage(image)
                
                // Stage B: Pre-generate AI caption
                if let interp = interpretation {
                    aiCaption = try await afmService.generateCaption(from: interp)
                }
                
                isPreprocessing = false
            } catch {
                print("Background processing error: \(error)")
                isPreprocessing = false
            }
        }
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
            // Check if we already have interpretation from background processing
            if interpretation == nil {
                // Stage A: Interpret image (if not done in background)
                interpretation = try await afmService.interpretImage(image)
            }
            
            guard let interp = interpretation else {
                showErrorMessage("Failed to interpret image")
                return
            }
            
            // Check if we already have AI caption from background processing
            if aiCaption == nil {
                // Stage B: Generate AI caption (if not done in background)
                aiCaption = try await afmService.generateCaption(from: interp)
            }
            
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

