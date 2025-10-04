import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var store: RideStore
    var body: some View {
        ZStack {
            DesignSystem.Gradients.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Ride History").font(.largeTitle.bold()).foregroundStyle(.white)
                    ForEach(store.rides) { ride in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack { Text(ride.date.formatted(date: .abbreviated, time: .shortened)); Spacer(); Text("Score \(String(format: "%.1f", ride.totalScore))") }
                                .foregroundStyle(.white)
                            RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.12)).frame(height: 100)
                            Text(ride.insight).foregroundStyle(.white.opacity(0.9)).font(.subheadline)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.12)))
                    }
                    if store.rides.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "car.fill").font(.system(size: 48)).foregroundStyle(.white)
                            Text("No Rides Yet").font(.title2.bold()).foregroundStyle(.white)
                            Text("Start your first ride to see your scores here").foregroundStyle(.white.opacity(0.85))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 80)
                    }
                }
                .padding()
            }
        }
    }
}


