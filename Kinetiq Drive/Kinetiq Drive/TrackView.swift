import SwiftUI
import CoreLocation

struct TrackView: View {
    @EnvironmentObject private var sensing: MotionSensingManager
    @EnvironmentObject private var analysis: AnalysisViewModel
    @EnvironmentObject private var location: LocationManager
    @State private var isPlaying: Bool = false

    var body: some View {
        ZStack {
            DesignSystem.Gradients.background.ignoresSafeArea()
            ParticleBackground().ignoresSafeArea()
            VStack(spacing: 20) {
                header
                ringControls
                overlays
                Spacer(minLength: 0)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 110)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }

    private var header: some View {
        HStack {
            GlowIcon(systemName: "play.circle.fill", size: 26)
            VStack(alignment: .leading, spacing: 4) {
                Text("Track")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                Text("Real‑time ride quality")
                    .foregroundStyle(.white.opacity(0.85))
            }
            Spacer()
        }
    }

    private var ringControls: some View {
        GeometryReader { geo in
            let base = min(geo.size.width, geo.size.height) * 0.55
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: max(12, base * 0.06))
                        .frame(width: base, height: base)
                    Circle()
                        .trim(from: 0, to: CGFloat(min(1, analysis.smoothnessScore/10)))
                        .stroke(DesignSystem.Gradients.score(for: analysis.smoothnessScore), style: StrokeStyle(lineWidth: max(12, base * 0.06), lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: base, height: base)
                        .animation(.easeInOut(duration: 0.3), value: analysis.smoothnessScore)
                    Circle()
                        .trim(from: 0, to: CGFloat(min(1, analysis.steadinessScore/10)))
                        .stroke(DesignSystem.Gradients.score(for: analysis.steadinessScore), style: StrokeStyle(lineWidth: max(8, base * 0.04), lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: base * 0.82, height: base * 0.82)
                        .animation(.easeInOut(duration: 0.3), value: analysis.steadinessScore)
                    Circle()
                        .trim(from: 0, to: CGFloat(min(1, analysis.stabilityScore/10)))
                        .stroke(DesignSystem.Gradients.score(for: analysis.stabilityScore), style: StrokeStyle(lineWidth: max(6, base * 0.03), lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: base * 0.66, height: base * 0.66)
                        .animation(.easeInOut(duration: 0.3), value: analysis.stabilityScore)

                    Button(action: toggle) {
                        ZStack {
                            Circle()
                                .fill(isPlaying ? DesignSystem.Colors.pauseGray : DesignSystem.Colors.playOrange)
                                .frame(width: max(88, base * 0.42), height: max(88, base * 0.42))
                                .shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: 10)
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .foregroundStyle(.white)
                                .font(.system(size: max(34, base * 0.16), weight: .bold))
                        }
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(isPlaying ? 0.98 : 1.02)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPlaying)
                }

                HStack(spacing: 16) {
                    Text(String(format: "%.1f km/h", location.speedMps * 3.6))
                        .foregroundStyle(.white)
                    Text(String(format: "%.2f km", location.distanceMeters / 1000))
                        .foregroundStyle(.white)
                    Text(String(format: "%.0f m", location.elevationMeters))
                        .foregroundStyle(.white)
                }
                .font(.headline)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 420)
    }

    private var overlays: some View {
        HStack(spacing: 12) {
            labelCard(icon: "cloud.sun.fill", title: "Weather", value: "—")
            labelCard(icon: "location.fill", title: "GPS", value: location.authorizationStatus == .authorizedAlways || location.authorizationStatus == .authorizedWhenInUse ? "On" : "Off")
        }
    }

    private func labelCard(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).foregroundStyle(.white)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.caption).foregroundStyle(.white.opacity(0.8))
                Text(value).font(.subheadline).foregroundStyle(.white)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .glassCard()
    }

    private func toggle() {
        if isPlaying {
            sensing.pause()
            location.stop()
        } else {
            sensing.start()
            location.request()
            location.start()
        }
        isPlaying.toggle()
    }
}


