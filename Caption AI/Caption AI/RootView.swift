//
//  RootView.swift
//  Caption Clash
//
//  Main navigation structure with bottom TabView
//

import SwiftUI
import SwiftData

struct RootView: View {
    @EnvironmentObject private var gameEngine: GameEngine
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Play Tab
            NavigationStack {
                PlayView()
            }
            .tabItem {
                Label("Play", systemImage: "gamecontroller.fill")
            }
            .tag(0)
            
            // History Tab
            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label("History", systemImage: "clock.fill")
            }
            .tag(1)
            
            // Badges Tab
            NavigationStack {
                BadgesView()
            }
            .tabItem {
                Label("Badges", systemImage: "rosette")
            }
            .badge(gameEngine.newBadgesCount > 0 ? "\(gameEngine.newBadgesCount)" : "")
            .tag(2)
            
            // Settings Tab
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(3)
        }
        .tint(.accent)
    }
}

#Preview {
    RootView()
        .environmentObject(AFMService())
        .environmentObject(GameEngine())
        .environmentObject(PhotoPickerService())
        .modelContainer(for: [RoundRecord.self, BadgeState.self], inMemory: true)
}

