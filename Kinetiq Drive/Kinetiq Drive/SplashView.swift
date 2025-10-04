import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.6
    @State private var opacity: Double = 0
    let completion: () -> Void

    var body: some View {
        ZStack {
            DesignSystem.Gradients.background.ignoresSafeArea()
            VStack(spacing: 16) {
                ZStack {
                    Circle().fill(Color.white.opacity(0.15)).frame(width: 160, height: 160)
                    Image(systemName: "car.fill")
                        .font(.system(size: 72, weight: .bold))
                        .foregroundStyle(.white)
                }
                .scaleEffect(scale)
                .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 10)

                Text("Ride IQ")
                    .font(.system(size: 40, weight: .black))
                    .foregroundStyle(.white)
                    .opacity(opacity)
                Text("Drive smoother. Enjoy more.")
                    .foregroundStyle(.white.opacity(0.85))
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) { scale = 1.0 }
            withAnimation(.easeIn(duration: 0.8).delay(0.4)) { opacity = 1 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { completion() }
        }
    }
}


