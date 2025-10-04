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
        VStack(spacing: 12) {
            Text("Ride IQ")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            GeometryReader { proxy in
                VStack(spacing: 12) {
                    LiveTrackingView()
                        .frame(height: proxy.size.height * 0.5)

                    VStack(spacing: 8) {
                        Picker("Section", selection: $selectedTab) {
                            Text("Live Metrics").tag(BottomTab.liveMetrics)
                            Text("Dashboard").tag(BottomTab.dashboard)
                        }
                        .pickerStyle(.segmented)

                        Group {
                            switch selectedTab {
                            case .liveMetrics:
                                LiveMetricsView()
                            case .dashboard:
                                DashboardView()
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(height: proxy.size.height * 0.5)
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding(.top)
        .background(Color(.systemBackground))
    }
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
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
            VStack(spacing: 8) {
                Text("Live Tracking")
                    .font(.headline)
                    .foregroundStyle(.primary)

                HStack(spacing: 16) {
                    Button(action: togglePlayPause) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 72, height: 72)
                            .background(Circle().fill(isPlaying ? Color.gray : Color.orange))
                    }
                    .accessibilityLabel(isPlaying ? "Pause" : "Play")

                    Button(action: stop) {
                        Text("Stop")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 72, height: 72)
                            .background(Circle().fill(Color.blue))
                    }
                    .accessibilityLabel("Stop")
                }

                VStack(spacing: 4) {
                    Text(String(format: "Vertical a: %.2f g", sensing.verticalAccelerationG))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "Lateral a: %.2f g", sensing.lateralAccelerationG))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "Rot x/y/z: %.2f / %.2f / %.2f rad/s", sensing.rotationRateX, sensing.rotationRateY, sensing.rotationRateZ))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
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
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                MetricCard(title: "Speed", value: "—", unit: "km/h")
                MetricCard(title: "Distance", value: "—", unit: "km")
            }
            HStack {
                MetricCard(title: "Duration", value: "—", unit: "min")
                MetricCard(title: "Elevation", value: "—", unit: "m")
            }
            Spacer(minLength: 0)
        }
    }
}

private struct DashboardView: View {
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
