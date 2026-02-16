import Testing
import Foundation
import MapKit
import CoreLocation
@testable import EuroTravelTranslate

// MARK: - POIResolver.mapCategory Tests

@Suite("POI Category Mapping Tests")
struct POICategoryMappingTests {

    @Test("Food POI categories map to .food")
    func foodCategories() {
        let categories: [MKPointOfInterestCategory] = [
            .restaurant, .cafe, .bakery, .brewery, .winery, .distillery, .foodMarket, .nightlife,
        ]
        for cat in categories {
            #expect(POIResolver.mapCategory(cat) == .food, "Expected .food for \(cat.rawValue)")
        }
    }

    @Test("Transport POI categories map to .transport")
    func transportCategories() {
        let categories: [MKPointOfInterestCategory] = [
            .airport, .publicTransport, .carRental, .gasStation, .evCharger, .parking, .marina,
        ]
        for cat in categories {
            #expect(POIResolver.mapCategory(cat) == .transport, "Expected .transport for \(cat.rawValue)")
        }
    }

    @Test("Shopping POI categories map to .shopping")
    func shoppingCategories() {
        let categories: [MKPointOfInterestCategory] = [
            .store, .pharmacy, .laundry, .beauty, .automotiveRepair, .animalService,
        ]
        for cat in categories {
            #expect(POIResolver.mapCategory(cat) == .shopping, "Expected .shopping for \(cat.rawValue)")
        }
    }

    @Test("Accommodation POI categories map to .accommodation")
    func accommodationCategories() {
        let categories: [MKPointOfInterestCategory] = [
            .hotel, .campground, .rvPark,
        ]
        for cat in categories {
            #expect(POIResolver.mapCategory(cat) == .accommodation, "Expected .accommodation for \(cat.rawValue)")
        }
    }

    @Test("Sightseeing POI categories map to .sightseeing")
    func sightseeingCategories() {
        let categories: [MKPointOfInterestCategory] = [
            .museum, .amusementPark, .aquarium, .zoo, .nationalPark, .park, .beach,
            .castle, .fortress, .landmark, .nationalMonument, .planetarium,
            .theater, .movieTheater, .musicVenue, .conventionCenter, .fairground,
            .stadium, .library,
        ]
        for cat in categories {
            #expect(POIResolver.mapCategory(cat) == .sightseeing, "Expected .sightseeing for \(cat.rawValue)")
        }
    }

    @Test("Unmapped POI categories return nil")
    func unmappedCategories() {
        let categories: [MKPointOfInterestCategory] = [
            .hospital, .police, .fireStation, .postOffice, .school, .university,
        ]
        for cat in categories {
            #expect(POIResolver.mapCategory(cat) == nil, "Expected nil for \(cat.rawValue)")
        }
    }
}

// MARK: - CategorySuggester Scoring Tests

@Suite("Category Scoring Tests")
struct CategoryScoringTests {
    let suggester = CategorySuggester()

    // MARK: - poiSuggestion distance-based confidence

    @Test("POI within 50m has confidence 0.9")
    func poiVeryClose() {
        let poi = POIResult(category: .food, poiName: "Test", distance: 30)
        let suggestion = suggester.poiSuggestion(from: poi)
        #expect(suggestion.confidence == 0.9)
        #expect(suggestion.category == .food)
    }

    @Test("POI at 50-99m has confidence 0.7")
    func poiClose() {
        let poi = POIResult(category: .shopping, poiName: "Test", distance: 75)
        let suggestion = suggester.poiSuggestion(from: poi)
        #expect(suggestion.confidence == 0.7)
        #expect(suggestion.category == .shopping)
    }

    @Test("POI at 100-199m has confidence 0.5")
    func poiMedium() {
        let poi = POIResult(category: .sightseeing, poiName: "Test", distance: 150)
        let suggestion = suggester.poiSuggestion(from: poi)
        #expect(suggestion.confidence == 0.5)
        #expect(suggestion.category == .sightseeing)
    }

    @Test("POI at 200m+ has confidence 0.3")
    func poiFar() {
        let poi = POIResult(category: .transport, poiName: "Test", distance: 250)
        let suggestion = suggester.poiSuggestion(from: poi)
        #expect(suggestion.confidence == 0.3)
        #expect(suggestion.category == .transport)
    }

    // MARK: - combine() scoring logic

    @Test("Both agree — confidence is boosted")
    func combineAgreement() {
        let time = CategorySuggestion(category: .food, confidence: 0.6, source: .timeOnly)
        let poi = CategorySuggestion(category: .food, confidence: 0.9, source: .poiOnly)
        let result = suggester.combine(time: time, poi: poi)
        #expect(result.category == .food)
        #expect(result.confidence == 1.0) // 0.9 + 0.1, capped at 1.0
        #expect(result.source == .combined)
    }

    @Test("Disagree, POI confident — POI wins")
    func combineDisagreePOIWins() {
        let time = CategorySuggestion(category: .food, confidence: 0.6, source: .timeOnly)
        let poi = CategorySuggestion(category: .sightseeing, confidence: 0.7, source: .poiOnly)
        let result = suggester.combine(time: time, poi: poi)
        #expect(result.category == .sightseeing)
        #expect(result.confidence == 0.7)
    }

    @Test("Disagree, POI not confident — time wins")
    func combineDisagreeTimeWins() {
        let time = CategorySuggestion(category: .food, confidence: 0.6, source: .timeOnly)
        let poi = CategorySuggestion(category: .transport, confidence: 0.3, source: .poiOnly)
        let result = suggester.combine(time: time, poi: poi)
        #expect(result.category == .food)
        #expect(result.confidence == 0.6)
    }

    @Test("POI exactly at 0.5 threshold — POI wins")
    func combineThresholdBoundary() {
        let time = CategorySuggestion(category: .food, confidence: 0.5, source: .timeOnly)
        let poi = CategorySuggestion(category: .shopping, confidence: 0.5, source: .poiOnly)
        let result = suggester.combine(time: time, poi: poi)
        #expect(result.category == .shopping)
    }

    // MARK: - suggest(at:poiResult:)

    @Test("No POI result falls back to time-based")
    func suggestNoPOI() {
        let result = suggester.suggest(at: Date(), poiResult: nil)
        #expect(result.source == .timeOnly)
    }

    @Test("With POI result returns combined")
    func suggestWithPOI() {
        let poi = POIResult(category: .sightseeing, poiName: "Museum", distance: 30)
        let result = suggester.suggest(at: Date(), poiResult: poi)
        #expect(result.category == .sightseeing)
    }

    // MARK: - Real scenario: restaurant near + dinner time

    @Test("Restaurant 30m at dinner → food with high confidence")
    func restaurantAtDinner() {
        var components = DateComponents()
        components.year = 2026
        components.month = 2
        components.day = 15
        components.hour = 19
        let dinnerDate = Calendar.current.date(from: components)!
        let poi = POIResult(category: .food, poiName: "Ristorante", distance: 30)
        let result = suggester.suggest(at: dinnerDate, poiResult: poi)
        #expect(result.category == .food)
        #expect(result.confidence == 1.0) // 0.9 + 0.1 boosted
        #expect(result.source == .combined)
    }

    @Test("Museum 30m at dinner → sightseeing (POI wins)")
    func museumAtDinner() {
        var components = DateComponents()
        components.year = 2026
        components.month = 2
        components.day = 15
        components.hour = 19
        let dinnerDate = Calendar.current.date(from: components)!
        let poi = POIResult(category: .sightseeing, poiName: "Louvre", distance: 30)
        let result = suggester.suggest(at: dinnerDate, poiResult: poi)
        #expect(result.category == .sightseeing)
        #expect(result.confidence == 0.9)
    }
}
