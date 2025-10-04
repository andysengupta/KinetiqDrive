import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject private var store: RideStore
    private var weekData: [ChartPoint] {
        let now = Date()
        return (0..<7).reversed().map { d in
            let date = Calendar.current.date(byAdding: .day, value: -d, to: now) ?? now
            let score = store.rides.randomElement()?.totalScore ?? Double(Int.random(in: 4...9))
            return ChartPoint(date: date, score: score)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                statGrid
                chart
                feed
                share
            }
            .padding()
        }
        .background(DesignSystem.Gradients.background.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Dashboard").font(.largeTitle.bold()).foregroundStyle(.white)
            Text("Track your progress").foregroundStyle(.white.opacity(0.85))
        }
    }

    private var statGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statCard(icon: "star.fill", title: "Recent Score", value: formatted(store.rides.first?.totalScore ?? 0))
            statCard(icon: "car.fill", title: "Total Rides", value: "\(store.rides.count)")
            statCard(icon: "chart.line.uptrend.xyaxis", title: "Average", value: formatted(averageScore()))
            statCard(icon: "arrow.up.circle.fill", title: "Improvement", value: "\(Int.random(in: 0...12))%")
        }
    }

    private func statCard(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon).foregroundStyle(.white)
            Text(value).font(.title2.bold()).foregroundStyle(.white)
            Text(title).font(.subheadline).foregroundStyle(.white.opacity(0.85))
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.15)))
    }

    private var chart: some View {
        VStack(alignment: .leading) {
            Text("Weekly Summary").foregroundStyle(.white)
            Chart(weekData) {
                LineMark(x: .value("Day", $0.date), y: .value("Score", $0.score))
                    .foregroundStyle(.white)
                PointMark(x: .value("Day", $0.date), y: .value("Score", $0.score))
                    .foregroundStyle(.white)
            }
            .frame(height: 180)
            .chartXAxis(.hidden)
            .chartYAxis(.automatic)
        }
    }

    private var feed: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent Rides").foregroundStyle(.white)
            ForEach(store.rides.prefix(5)) { ride in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(ride.date.formatted(date: .abbreviated, time: .shortened)).foregroundStyle(.white)
                        Spacer()
                        Text("\(formatted(ride.totalScore))/10").foregroundStyle(.white)
                    }
                    RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.12)).frame(height: 80)
                    Text(ride.insight).foregroundStyle(.white.opacity(0.9)).font(.subheadline)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.12)))
            }
            if store.rides.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("No Rides Yet").font(.headline).foregroundStyle(.white)
                    Text("Start your first ride to see insights here.").foregroundStyle(.white.opacity(0.85))
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.12)))
            }
        }
    }

    private var share: some View {
        Button {
        } label: {
            HStack {
                Image(systemName: "square.and.arrow.up"); Text("Share Ride").bold()
            }
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.15)))
        }
    }

    private func formatted(_ d: Double) -> String { String(format: "%.1f", d) }
    private func averageScore() -> Double {
        guard !store.rides.isEmpty else { return 0 }
        return store.rides.map { $0.totalScore }.reduce(0, +) / Double(store.rides.count)
    }
}

struct ChartPoint: Identifiable { let id = UUID(); let date: Date; let score: Double }


