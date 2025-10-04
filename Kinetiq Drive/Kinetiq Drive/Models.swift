import Foundation
import CoreLocation

struct Ride: Identifiable, Codable {
    let id: UUID
    let date: Date
    var durationSec: Int
    var distanceMeters: Double
    var elevationGainMeters: Double
    var totalScore: Double
    var smoothness: Double
    var stability: Double
    var steadiness: Double
    var insight: String
    var route: [CLLocationCoordinate2DWrapper]
}

struct CLLocationCoordinate2DWrapper: Codable, Hashable {
    let latitude: Double
    let longitude: Double
}

final class RideStore: ObservableObject {
    @Published private(set) var rides: [Ride] = []
    private let key = "ride_store_rides_v1"

    init() {
        load()
    }

    func add(_ ride: Ride) {
        rides.insert(ride, at: 0)
        save()
    }

    func reset() {
        rides.removeAll()
        save()
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(rides)
            UserDefaults.standard.set(data, forKey: key)
        } catch { }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        if let r = try? JSONDecoder().decode([Ride].self, from: data) {
            rides = r
        }
    }
}


