//
//  CaptionClashApp.swift
//  Caption Clash
//
//  Production-ready app entry point for iOS 19+
//  Uses modern App lifecycle with @main and ScenePhase
//

import SwiftUI
import SwiftData

@main
struct CaptionClashApp: App {
    // SwiftData model container (on-device only, no iCloud)
    let modelContainer: ModelContainer
    
    // Core services injected as environment objects
    @StateObject private var afmService = AFMService()
    @StateObject private var gameEngine = GameEngine()
    @StateObject private var photoPickerService = PhotoPickerService()
    
    // Scene phase tracking for lifecycle management
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        // Configure SwiftData with local-only persistence
        do {
            let schema = Schema([
                RoundRecord.self,
                BadgeState.self
            ])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .none // Explicit: no cloud sync
            )
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not initialize SwiftData container: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(modelContainer)
                .environmentObject(afmService)
                .environmentObject(gameEngine)
                .environmentObject(photoPickerService)
                .onAppear {
                    // Check AFM availability on launch
                    Task {
                        await afmService.checkAvailability()
                    }
                }
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    handleScenePhaseChange(from: oldPhase, to: newPhase)
                }
        }
    }
    
    /// Handle app lifecycle transitions
    private func handleScenePhaseChange(from old: ScenePhase, to new: ScenePhase) {
        switch new {
        case .active:
            // Recheck AFM when returning to foreground
            Task {
                await afmService.checkAvailability()
            }
            // Update daily streak
            gameEngine.checkDailyStreak()
            
        case .background:
            // Clean up AFM sessions to free memory
            afmService.cleanupSessions()
            
        case .inactive:
            break
            
        @unknown default:
            break
        }
    }
}

