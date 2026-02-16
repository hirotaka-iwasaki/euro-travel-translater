import CoreLocation
import os

protocol LocationServiceProtocol: Sendable {
    func requestLocation() async -> CLLocation?
}

final class LocationService: NSObject, CLLocationManagerDelegate, LocationServiceProtocol, @unchecked Sendable {

    static let shared = LocationService()

    private let manager: CLLocationManager
    private let lock = OSAllocatedUnfairLock<State>(initialState: State())

    private struct State {
        var continuation: CheckedContinuation<CLLocation?, Never>?
        var cachedLocation: CLLocation?
        var cacheTimestamp: Date?
    }

    private static let cacheInterval: TimeInterval = 30

    override init() {
        self.manager = CLLocationManager()
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestLocation() async -> CLLocation? {
        // Check cache
        let cached: CLLocation? = lock.withLock { state in
            if let loc = state.cachedLocation,
               let ts = state.cacheTimestamp,
               Date().timeIntervalSince(ts) < Self.cacheInterval {
                return loc
            }
            return nil
        }
        if let cached { return cached }

        let status = manager.authorizationStatus
        if status == .denied || status == .restricted {
            AppLogger.location.debug("Location authorization denied/restricted")
            return nil
        }

        return await withCheckedContinuation { continuation in
            let shouldRequest = lock.withLock { state -> Bool in
                if state.continuation != nil {
                    // Already an in-flight request — this shouldn't happen often
                    // but guard against it
                    return false
                }
                state.continuation = continuation
                return true
            }

            guard shouldRequest else {
                continuation.resume(returning: nil)
                return
            }

            if status == .notDetermined {
                manager.requestWhenInUseAuthorization()
            } else {
                manager.requestLocation()
            }
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        AppLogger.location.debug("Authorization changed: \(status.rawValue)")

        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            // If we have a pending continuation, start location request
            let hasPending = lock.withLock { $0.continuation != nil }
            if hasPending {
                manager.requestLocation()
            }
        case .denied, .restricted:
            let cont = lock.withLock { state -> CheckedContinuation<CLLocation?, Never>? in
                let c = state.continuation
                state.continuation = nil
                return c
            }
            cont?.resume(returning: nil)
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let validLocation: CLLocation? = if let loc = location, loc.horizontalAccuracy <= 500 {
            loc
        } else {
            nil
        }

        let cont = lock.withLock { state -> CheckedContinuation<CLLocation?, Never>? in
            if let validLocation {
                state.cachedLocation = validLocation
                state.cacheTimestamp = Date()
            }
            let c = state.continuation
            state.continuation = nil
            return c
        }
        cont?.resume(returning: validLocation)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        AppLogger.location.error("Location error: \(error.localizedDescription)")
        let cont = lock.withLock { state -> CheckedContinuation<CLLocation?, Never>? in
            let c = state.continuation
            state.continuation = nil
            return c
        }
        cont?.resume(returning: nil)
    }
}
