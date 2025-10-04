//
//  AnalysisViewModel.swift
//  Ride IQ
//
//  Created by Assistant on 04.10.25.
//

import Foundation
import Combine

final class AnalysisViewModel: ObservableObject {
    struct Sample {
        let time: TimeInterval
        let verticalG: Double
        let lateralG: Double
        let rotationMag: Double
    }

    @Published private(set) var smoothnessScore: Double = 0 // lateral
    @Published private(set) var stabilityScore: Double = 0 // vertical
    @Published private(set) var steadinessScore: Double = 0 // rotation

    private var samples: [Sample] = []
    private var cancellables = Set<AnyCancellable>()
    private let window: TimeInterval = 60

    init(sensing: MotionSensingManager) {
        // Sample whenever motion changes; throttle lightly to avoid excessive work
        sensing.$lateralAccelerationG
            .combineLatest(sensing.$verticalAccelerationG, sensing.$rotationRateX, sensing.$rotationRateY, sensing.$rotationRateZ)
            .receive(on: DispatchQueue.main)
            .throttle(for: .milliseconds(250), scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] lateral, vertical, rx, ry, rz in
                self?.ingest(lateral: lateral, vertical: vertical, rotationMag: sqrt(rx*rx + ry*ry + rz*rz))
            }
            .store(in: &cancellables)
    }

    private func ingest(lateral: Double, vertical: Double, rotationMag: Double) {
        let now = Date().timeIntervalSince1970
        samples.append(.init(time: now, verticalG: abs(vertical), lateralG: abs(lateral), rotationMag: abs(rotationMag)))
        prune(now: now)
        computeScores()
    }

    private func prune(now: TimeInterval) {
        let cutoff = now - window
        if let idx = samples.firstIndex(where: { $0.time >= cutoff }) {
            if idx > 0 { samples.removeFirst(idx) }
        } else {
            samples.removeAll(keepingCapacity: true)
        }
    }

    private func computeScores() {
        guard !samples.isEmpty else {
            smoothnessScore = 0
            stabilityScore = 0
            steadinessScore = 0
            return
        }
        // Aggregate as RMS within window
        let count = Double(samples.count)
        let rmsLateral = sqrt(samples.reduce(0) { $0 + $1.lateralG * $1.lateralG } / count)
        let rmsVertical = sqrt(samples.reduce(0) { $0 + $1.verticalG * $1.verticalG } / count)
        let rmsRotation = sqrt(samples.reduce(0) { $0 + $1.rotationMag * $1.rotationMag } / count)

        smoothnessScore = mapToScore(invertedMagnitude: rmsLateral, scale: 1.2) // ~0.3g→7.5, 0.6g→5
        stabilityScore = mapToScore(invertedMagnitude: rmsVertical, scale: 1.0)
        steadinessScore = mapToScore(invertedMagnitude: rmsRotation, scale: 6.0) // rad/s
    }

    private func mapToScore(invertedMagnitude value: Double, scale: Double) -> Double {
        // Higher magnitude -> lower score. score = 10 - k*value, clamped 0...10
        let score = 10.0 - (value * scale * 10.0 / 1.0)
        return max(0, min(10, score))
    }

    func label(for score: Double) -> String {
        switch score {
        case 8.5...10: return "Excellent"
        case 7...8.5: return "Very Good"
        case 5.5...7: return "Good"
        case 4...5.5: return "Average"
        case 2.5...4: return "Rough"
        default: return "Harsh"
        }
    }
}


