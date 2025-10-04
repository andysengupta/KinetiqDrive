import SwiftUI

struct GlowIcon: View {
    let systemName: String
    let size: CGFloat
    var body: some View {
        ZStack {
            Circle().fill(DesignSystem.Colors.glassFill).frame(width: size*1.6, height: size*1.6)
                .shadow(color: DesignSystem.Colors.brandB.opacity(0.6), radius: 16, x: 0, y: 6)
            Image(systemName: systemName)
                .font(.system(size: size, weight: .bold))
                .foregroundStyle(DesignSystem.Gradients.glow())
        }
    }
}


