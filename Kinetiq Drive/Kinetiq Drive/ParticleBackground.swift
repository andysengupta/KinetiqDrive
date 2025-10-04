import SwiftUI

struct ParticleBackground: View {
    @State private var t: CGFloat = 0
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let colors: [Color] = [Color.white.opacity(0.15), Color.white.opacity(0.08)]
                for i in 0..<60 {
                    let phase = (t + CGFloat(i)) / 30
                    let x = CGFloat(truncating: NSNumber(value: sin(Double(phase))*0.5 + 0.5)) * size.width
                    let y = CGFloat(truncating: NSNumber(value: cos(Double(phase*1.3))*0.5 + 0.5)) * size.height
                    let r: CGFloat = 2 + CGFloat((i % 5))
                    let rect = CGRect(x: x, y: y, width: r, height: r)
                    context.fill(Path(ellipseIn: rect), with: .color(colors[i % colors.count]))
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear { withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) { t = 60 } }
    }
}


