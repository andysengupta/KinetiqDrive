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
            VStack(spacing: 16) {
                header
                ringControls
                overlays
                Spacer(minLength: 0)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
    }

    private var header: some View {
        HStack {
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
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 14)
                    .frame(width: 220, height: 220)
                Circle()
                    .trim(from: 0, to: CGFloat(min(1, analysis.smoothnessScore/10)))
                    .stroke(DesignSystem.Gradients.score(for: analysis.smoothnessScore), style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 220, height: 220)
                    .animation(.easeInOut(duration: 0.3), value: analysis.smoothnessScore)
                Circle()
                    .trim(from: 0, to: CGFloat(min(1, analysis.steadinessScore/10)))
                    .stroke(DesignSystem.Gradients.score(for: analysis.steadinessScore), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 180, height: 180)
                    .animation(.easeInOut(duration: 0.3), value: analysis.steadinessScore)
                Circle()
                    .trim(from: 0, to: CGFloat(min(1, analysis.stabilityScore/10)))
                    .stroke(DesignSystem.Gradients.score(for: analysis.stabilityScore), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 150, height: 150)
                    .animation(.easeInOut(duration: 0.3), value: analysis.stabilityScore)

                Button(action: toggle) {
                    ZStack {
                        Circle()
                            .fill(isPlaying ? DesignSystem.Colors.pauseGray : DesignSystem.Colors.playOrange)
                            .frame(width: 96, height: 96)
                            .shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: 10)
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .foregroundStyle(.white)
                            .font(.system(size: 36, weight: .bold))
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
    }

    private var overlays: some View {
        HStack(spacing: 12) {
            labelCard(icon: "cloud.sun", title: "Weather", value: "—")
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
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.12)))
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


