import SwiftUI

struct StatsView: View {
    @State private var scope: Int = 0
    var body: some View {
        ZStack {
            DesignSystem.Gradients.background.ignoresSafeArea()
            VStack(spacing: 16) {
                Text("Statistics").font(.largeTitle.bold()).foregroundStyle(.white)
                Picker("Scope", selection: $scope) {
                    Text("Week").tag(0); Text("Month").tag(1); Text("Year").tag(2); Text("All Time").tag(3)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis").font(.system(size: 64)).foregroundStyle(.white.opacity(0.8))
                    Text("No Data Yet").font(.title.bold()).foregroundStyle(.white)
                    Text("Complete a few rides to see your statistics").foregroundStyle(.white.opacity(0.85))
                }
                Spacer()
                Button(action: {}) {
                    Text("Reset All Data").bold().frame(maxWidth: .infinity).padding().background(RoundedRectangle(cornerRadius: 16).fill(Color.red))
                }
                .padding(.horizontal)
                Spacer(minLength: 40)
            }
        }
    }
}


