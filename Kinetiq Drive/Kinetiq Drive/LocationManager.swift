import Foundation
import CoreLocation
import Combine

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published private(set) var speedMps: Double = 0
    @Published private(set) var distanceMeters: Double = 0
    @Published private(set) var elevationMeters: Double = 0
    @Published private(set) var route: [CLLocationCoordinate2DWrapper] = []

    private let manager = CLLocationManager()
    private var lastLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.activityType = .automotiveNavigation
    }

    func request() {
        manager.requestWhenInUseAuthorization()
    }

    func start() {
        manager.startUpdatingLocation()
    }

    func stop() {
        manager.stopUpdatingLocation()
        lastLocation = nil
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        speedMps = max(0, loc.speed)
        elevationMeters = loc.altitude
        if let last = lastLocation {
            distanceMeters += loc.distance(from: last)
        }
        lastLocation = loc
        route.append(.init(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude))
    }
}


