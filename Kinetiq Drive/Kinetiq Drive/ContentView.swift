//
//  ContentView.swift
//  Kinetiq Drive
//
//  Created by Anand Sengupta on 04.10.25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: BottomTab = .liveMetrics

    var body: some View {
        ZStack {
            DesignSystem.Gradients.background.ignoresSafeArea()
            VStack(spacing: 12) {
                header
                GeometryReader { proxy in
                    VStack(spacing: 12) {
                        LiveTrackingView()
                            .frame(height: proxy.size.height * 0.5)

                        VStack(spacing: 10) {
                            PillSegmentedControl(selection: $selectedTab)
                            Group {
                                switch selectedTab {
                                case .liveMetrics:
                                    LiveMetricsView()
                                case .dashboard:
                                    DashboardPlaceholderView()
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .glassCard()
                        }
                        .frame(height: proxy.size.height * 0.5)
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding(.top)
        }
    }
}
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Ride IQ")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                Text("Drive smarter. Ride smoother.")
                    .foregroundStyle(.white.opacity(0.8))
            }
            Spacer()
        }
        .padding(.horizontal)
    }

#Preview {
    ContentView()
}

private enum BottomTab: Hashable {
    case liveMetrics
    case dashboard
}

private struct LiveTrackingView: View {
    @EnvironmentObject private var sensing: MotionSensingManager
    @State private var isPlaying: Bool = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.Radius.card)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.Radius.card)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            VStack(spacing: 12) {
                Text("Live Tracking")
                    .font(.headline)
                    .foregroundStyle(.white)

                ControlRow(isPlaying: $isPlaying, playAction: togglePlayPause, stopAction: stop)

                VStack(spacing: 4) {
                    Text(String(format: "Vertical a: %.2f g", sensing.verticalAccelerationG))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.9))
                    Text(String(format: "Lateral a: %.2f g", sensing.lateralAccelerationG))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.9))
                    Text(String(format: "Rot x/y/z: %.2f / %.2f / %.2f rad/s", sensing.rotationRateX, sensing.rotationRateY, sensing.rotationRateZ))
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            .padding()
        }
        .padding(.horizontal)
    }

    private func togglePlayPause() {
        if isPlaying {
            sensing.pause()
            isPlaying = false
        } else {
            sensing.start()
            isPlaying = true
        }
    }

    private func stop() {
        sensing.stop()
        isPlaying = false
    }
}

private struct LiveMetricsView: View {
    @EnvironmentObject private var analysis: AnalysisViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScoreBar(title: "Smoothness", value: analysis.smoothnessScore, label: analysis.label(for: analysis.smoothnessScore))
            ScoreBar(title: "Stability", value: analysis.stabilityScore, label: analysis.label(for: analysis.stabilityScore))
            ScoreBar(title: "Steadiness", value: analysis.steadinessScore, label: analysis.label(for: analysis.steadinessScore))
            Spacer(minLength: 0)
        }
    }
}

private struct DashboardPlaceholderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dashboard")
                .font(.headline)
            Text("Insights and recent rides will be shown here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct MetricCard: View {
    let title: String
    let value: String
    let unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(value)
                    .font(.title2).bold()
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

private struct PillSegmentedControl: View {
    @Binding var selection: BottomTab
    var body: some View {
        HStack(spacing: 4) {
            pill(title: "Live Metrics", tab: .liveMetrics)
            pill(title: "Dashboard", tab: .dashboard)
        }
        .padding(6)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: DesignSystem.Radius.pill).fill(DesignSystem.Colors.pillBackground))
    }

    private func pill(title: String, tab: BottomTab) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selection = tab
                Haptics.impact(.light)
            }
        } label: {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(selection == tab ? .white : .secondary)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(
                    ZStack {
                        if selection == tab {
                            RoundedRectangle(cornerRadius: DesignSystem.Radius.pill)
                                .fill(.ultraThinMaterial)
                                .transition(.opacity.combined(with: .scale))
                        }
                    }
                )
        }
    }
}

private struct ControlRow: View {
    @Binding var isPlaying: Bool
    var playAction: () -> Void
    var stopAction: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button(action: {
                Haptics.impact(.heavy)
                playAction()
            }) {
                ZStack {
                    Circle()
                        .fill(isPlaying ? DesignSystem.Colors.pauseGray : DesignSystem.Colors.playOrange)
                        .frame(width: 76, height: 76)
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .accessibilityLabel(isPlaying ? "Pause" : "Play")

            Button(action: {
                Haptics.warning()
                stopAction()
            }) {
                ZStack {
                    Circle()
                        .fill(DesignSystem.Colors.stopBlue)
                        .frame(width: 76, height: 76)
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    Text("Stop")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }
            .accessibilityLabel("Stop")
        }
    }
}

private struct ScoreBar: View {
    let title: String
    let value: Double
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(String(format: "%.1f", value))
                    .font(.headline)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.tertiarySystemFill))
                        .frame(height: 16)
                    RoundedRectangle(cornerRadius: 10)
                        .fill(DesignSystem.Gradients.score(for: value))
                        .frame(width: max(8, CGFloat(value/10.0) * geo.size.width), height: 16)
                        .animation(.easeOut(duration: 0.3), value: value)
                }
            }
            .frame(height: 16)
            Text(label)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
        }
        .padding()
        .glassCard()
    }
}
