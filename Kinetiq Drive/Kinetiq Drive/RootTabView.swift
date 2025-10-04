import SwiftUI

struct RootTabView: View {
    var body: some View {
        ZStack {
            // Full-screen background to extend under the tab bar and on tall devices
            DesignSystem.Gradients.background.ignoresSafeArea()
            ParticleBackground().ignoresSafeArea()
            TabView {
                TrackView()
                    .tabItem { Label("Track", systemImage: "play.circle.fill") }
                HistoryView()
                    .tabItem { Label("History", systemImage: "clock") }
                DashboardView()
                    .tabItem { Label("Dashboard", systemImage: "gauge.with.dots.needle.bottom.50percent") }
                StatsView()
                    .tabItem { Label("Stats", systemImage: "chart.bar.xaxis") }
            }
            .background(Color.clear)
            .tint(.blue)
        }
        // Force TabView to float over content by reserving space visually
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 30)
        }
    }
}


