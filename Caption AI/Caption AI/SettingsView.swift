//
//  SettingsView.swift
//  Caption Clash
//
//  Settings: AFM status, privacy info, data management, diagnostics
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var afmService: AFMService
    @EnvironmentObject private var gameEngine: GameEngine
    
    @Query private var rounds: [RoundRecord]
    @Query private var badges: [BadgeState]
    
    @State private var showEraseConfirmation = false
    @State private var showEraseSuccess = false
    
    var body: some View {
        List {
            // AI Status Section
            Section {
                HStack {
                    Label("AI Status", systemImage: SFSymbols.brain)
                    Spacer()
                    statusIndicator
                }
                
                Text(afmService.availabilityStatus)
                    .font(Typography.caption)
                    .foregroundStyle(.secondary)
                
                if !afmService.isAvailable {
                    Button {
                        Task {
                            await afmService.checkAvailability()
                        }
                        Haptics.selectionChanged()
                    } label: {
                        Label("Recheck Availability", systemImage: "arrow.clockwise")
                    }
                }
            } header: {
                Text("Apple Intelligence")
            } footer: {
                Text("Caption Clash uses on-device AI (Apple Foundation Models) for image analysis and caption generation. No data leaves your device.")
            }
            
            // Privacy Section
            Section {
                HStack {
                    Label("Privacy Mode", systemImage: SFSymbols.shield)
                    Spacer()
                    Image(systemName: SFSymbols.checkmark)
                        .foregroundStyle(.green)
                }
                
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("✓ All processing on-device")
                    Text("✓ No cloud services")
                    Text("✓ No data collection")
                    Text("✓ No analytics or tracking")
                }
                .font(Typography.caption)
                .foregroundStyle(.secondary)
                
            } header: {
                Text("Privacy")
            } footer: {
                Text("Your photos and captions never leave your device. We don't collect any personal data or usage statistics.")
            }
            
            // Data Management Section
            Section {
                HStack {
                    Label("Stored Rounds", systemImage: SFSymbols.clock)
                    Spacer()
                    Text("\(rounds.count)")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Label("Unlocked Badges", systemImage: SFSymbols.badge)
                    Spacer()
                    Text("\(badges.filter { $0.isUnlocked }.count)/\(Badge.allCases.count)")
                        .foregroundStyle(.secondary)
                }
                
                Button(role: .destructive) {
                    showEraseConfirmation = true
                    Haptics.selectionChanged()
                } label: {
                    Label("Erase All Data", systemImage: SFSymbols.trash)
                }
            } header: {
                Text("Data")
            } footer: {
                Text("Erase all game history, scores, and progress. This cannot be undone.")
            }
            
            // App Info Section
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Build")
                    Spacer()
                    Text("100")
                        .foregroundStyle(.secondary)
                }
                
                Link(destination: URL(string: "https://www.apple.com/ios/")!) {
                    Label("Learn About Apple Intelligence", systemImage: SFSymbols.info)
                }
            } header: {
                Text("About")
            }
        }
        .navigationTitle("Settings")
        .alert("Erase All Data?", isPresented: $showEraseConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Erase", role: .destructive) {
                eraseAllData()
            }
        } message: {
            Text("This will permanently delete all your rounds, scores, and badge progress. This action cannot be undone.")
        }
        .alert("Data Erased", isPresented: $showEraseSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("All game data has been successfully erased.")
        }
    }
    
    // MARK: - Status Indicator
    
    private var statusIndicator: some View {
        HStack(spacing: Spacing.xs) {
            Circle()
                .fill(afmService.isAvailable ? .green : .orange)
                .frame(width: 8, height: 8)
            
            Text(afmService.isAvailable ? "Ready" : "Unavailable")
                .font(Typography.caption)
                .foregroundStyle(afmService.isAvailable ? .green : .orange)
        }
    }
    
    // MARK: - Data Management
    
    private func eraseAllData() {
        // Delete all rounds
        for round in rounds {
            modelContext.delete(round)
        }
        
        // Delete all badge states
        for badge in badges {
            modelContext.delete(badge)
        }
        
        // Reset game engine
        gameEngine.currentStreak = 0
        gameEngine.lastPlayedDate = nil
        gameEngine.newBadgesCount = 0
        
        do {
            try modelContext.save()
            showEraseSuccess = true
            Haptics.success()
        } catch {
            print("Failed to erase data: \(error)")
            Haptics.error()
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environmentObject(AFMService())
    .environmentObject(GameEngine())
    .modelContainer(for: [RoundRecord.self, BadgeState.self], inMemory: true)
}

