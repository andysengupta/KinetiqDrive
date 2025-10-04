//
//  ConfettiView.swift
//  Caption Clash
//
//  Celebratory confetti animation for high scores and achievements
//

import SwiftUI

struct ConfettiView: View {
    let particleCount: Int = 50
    @State private var particles: [ConfettiParticle] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                generateParticles(in: geometry.size)
                animateParticles()
            }
        }
        .allowsHitTesting(false)
    }
    
    private func generateParticles(in size: CGSize) {
        particles = (0..<particleCount).map { _ in
            ConfettiParticle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: -20
                ),
                size: CGFloat.random(in: 8...16),
                color: [.red, .blue, .green, .yellow, .purple, .orange, .pink].randomElement()!,
                velocity: CGFloat.random(in: 2...6),
                opacity: 1.0
            )
        }
    }
    
    private func animateParticles() {
        withAnimation(.linear(duration: 3.0)) {
            for index in particles.indices {
                particles[index].position.y += 1000
                particles[index].opacity = 0
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size: CGFloat
    let color: Color
    let velocity: CGFloat
    var opacity: Double
}

// MARK: - Confetti Overlay Modifier

struct ConfettiOverlay: ViewModifier {
    let isActive: Bool
    @State private var show = false
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if show {
                    ConfettiView()
                        .transition(.opacity)
                }
            }
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    show = true
                    // Auto-hide after animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                        show = false
                    }
                }
            }
    }
}

extension View {
    func confetti(isActive: Bool) -> some View {
        self.modifier(ConfettiOverlay(isActive: isActive))
    }
}

