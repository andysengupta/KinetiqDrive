import SwiftUI

struct RootTabView: View {
    var body: some View {
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
        .tint(.blue)
    }
}


