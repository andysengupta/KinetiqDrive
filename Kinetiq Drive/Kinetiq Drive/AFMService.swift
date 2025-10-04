import Foundation

struct AFMResult {
    let smoothness: Double
    let stability: Double
    let steadiness: Double
    let labels: (String, String, String)
}

protocol AFMAnalyzing {
    func analyze(last60Samples: [(verticalG: Double, lateralG: Double, rotation: Double)]) -> AFMResult
}

// Placeholder heuristic in lieu of on-device AFM. Swap impl when AFM APIs available.
final class AFMService: AFMAnalyzing {
    func analyze(last60Samples: [(verticalG: Double, lateralG: Double, rotation: Double)]) -> AFMResult {
        guard !last60Samples.isEmpty else {
            return AFMResult(smoothness: 0, stability: 0, steadiness: 0, labels: ("—","—","—"))
        }
        let n = Double(last60Samples.count)
        let rmsL = sqrt(last60Samples.reduce(0) { $0 + $1.lateralG*$1.lateralG } / n)
        let rmsV = sqrt(last60Samples.reduce(0) { $0 + $1.verticalG*$1.verticalG } / n)
        let rmsR = sqrt(last60Samples.reduce(0) { $0 + $1.rotation*$1.rotation } / n)
        func score(_ v: Double, scale: Double) -> Double { max(0, min(10, 10 - v*scale*10)) }
        let sL = score(rmsL, scale: 1.2)
        let sV = score(rmsV, scale: 1.0)
        let sR = score(rmsR, scale: 6.0)
        func label(_ s: Double) -> String {
            switch s { case 8.5...: return "Silky"; case 7...8.5: return "Smooth"; case 5.5...7: return "Steady"; case 4...5.5: return "Okay"; case 2.5...4: return "Rough"; default: return "Harsh" }
        }
        return AFMResult(smoothness: sL, stability: sV, steadiness: sR, labels: (label(sL), label(sV), label(sR)))
    }
}


