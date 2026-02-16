import CoreLocation
import MapKit

struct POIResult: Sendable {
    let category: ExpenseCategory
    let poiName: String?
    let distance: CLLocationDistance
}

protocol POIResolverProtocol: Sendable {
    func resolve(at location: CLLocation) async -> POIResult?
}

struct POIResolver: POIResolverProtocol {

    func resolve(at location: CLLocation) async -> POIResult? {
        let region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 400,
            longitudinalMeters: 400
        )
        let request = MKLocalPointsOfInterestRequest(coordinateRegion: region)
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: Self.supportedCategories)

        let search = MKLocalSearch(request: request)
        let response: MKLocalSearch.Response
        do {
            response = try await search.start()
        } catch {
            AppLogger.location.debug("POI search failed: \(error.localizedDescription)")
            return nil
        }

        let results: [(item: MKMapItem, category: ExpenseCategory, distance: CLLocationDistance)] = response.mapItems.compactMap { item in
            guard let poiCategory = item.pointOfInterestCategory,
                  let mapped = Self.mapCategory(poiCategory) else { return nil }
            let dist = location.distance(from: CLLocation(
                latitude: item.placemark.coordinate.latitude,
                longitude: item.placemark.coordinate.longitude
            ))
            return (item, mapped, dist)
        }

        guard let nearest = results.min(by: { $0.distance < $1.distance }) else {
            return nil
        }

        AppLogger.location.debug("Nearest POI: \(nearest.item.name ?? "unknown") (\(nearest.category.rawValue)) at \(Int(nearest.distance))m")
        return POIResult(
            category: nearest.category,
            poiName: nearest.item.name,
            distance: nearest.distance
        )
    }

    // MARK: - Category Mapping (pure function, testable)

    static func mapCategory(_ poiCategory: MKPointOfInterestCategory) -> ExpenseCategory? {
        switch poiCategory {
        // food
        case .restaurant, .cafe, .bakery, .brewery, .winery, .distillery, .foodMarket, .nightlife:
            return .food
        // transport
        case .airport, .publicTransport, .carRental, .gasStation, .evCharger, .parking, .marina:
            return .transport
        // shopping
        case .store, .pharmacy, .laundry, .beauty, .automotiveRepair, .animalService:
            return .shopping
        // accommodation
        case .hotel, .campground, .rvPark:
            return .accommodation
        // sightseeing
        case .museum, .amusementPark, .aquarium, .zoo, .nationalPark, .park, .beach,
             .castle, .fortress, .landmark, .nationalMonument, .planetarium,
             .theater, .movieTheater, .musicVenue, .conventionCenter, .fairground,
             .stadium, .library:
            return .sightseeing
        default:
            return nil
        }
    }

    // MARK: - Supported POI categories for search filter

    private static let supportedCategories: [MKPointOfInterestCategory] = [
        // food
        .restaurant, .cafe, .bakery, .brewery, .winery, .distillery, .foodMarket, .nightlife,
        // transport
        .airport, .publicTransport, .carRental, .gasStation, .evCharger, .parking, .marina,
        // shopping
        .store, .pharmacy, .laundry, .beauty, .automotiveRepair, .animalService,
        // accommodation
        .hotel, .campground, .rvPark,
        // sightseeing
        .museum, .amusementPark, .aquarium, .zoo, .nationalPark, .park, .beach,
        .castle, .fortress, .landmark, .nationalMonument, .planetarium,
        .theater, .movieTheater, .musicVenue, .conventionCenter, .fairground,
        .stadium, .library,
    ]
}
