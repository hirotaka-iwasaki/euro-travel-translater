import Foundation
import CoreLocation

// MARK: - CategorySuggestion

enum SuggestionSource: Sendable {
    case timeOnly
    case poiOnly
    case combined
}

struct CategorySuggestion: Sendable {
    let category: ExpenseCategory
    let confidence: Double
    let source: SuggestionSource
}

// MARK: - CategorySuggester

struct CategorySuggester: Sendable {

    // MARK: - Legacy (backwards compatible)

    func suggest(at date: Date = Date()) -> ExpenseCategory {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 7..<10:
            return .food
        case 11..<14:
            return .food
        case 17..<21:
            return .food
        default:
            return .other
        }
    }

    // MARK: - Time-based suggestion with confidence

    func timeSuggestion(at date: Date = Date()) -> CategorySuggestion {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 7..<10:
            return CategorySuggestion(category: .food, confidence: 0.5, source: .timeOnly)
        case 11..<14:
            return CategorySuggestion(category: .food, confidence: 0.6, source: .timeOnly)
        case 17..<21:
            return CategorySuggestion(category: .food, confidence: 0.6, source: .timeOnly)
        default:
            return CategorySuggestion(category: .other, confidence: 0.2, source: .timeOnly)
        }
    }

    // MARK: - POI-based suggestion with distance confidence

    func poiSuggestion(from poi: POIResult) -> CategorySuggestion {
        let confidence: Double
        switch poi.distance {
        case 0..<50:
            confidence = 0.9
        case 50..<100:
            confidence = 0.7
        case 100..<200:
            confidence = 0.5
        default:
            confidence = 0.3
        }
        return CategorySuggestion(category: poi.category, confidence: confidence, source: .poiOnly)
    }

    // MARK: - Combined suggestion

    func suggest(at date: Date = Date(), poiResult: POIResult?) -> CategorySuggestion {
        let time = timeSuggestion(at: date)
        guard let poi = poiResult else { return time }
        let poiSug = poiSuggestion(from: poi)
        return combine(time: time, poi: poiSug)
    }

    func combine(time: CategorySuggestion, poi: CategorySuggestion) -> CategorySuggestion {
        if time.category == poi.category {
            // Both agree — boost confidence
            let boosted = min(poi.confidence + 0.1, 1.0)
            return CategorySuggestion(category: poi.category, confidence: boosted, source: .combined)
        }

        // Disagree — POI wins if sufficiently confident
        if poi.confidence >= 0.5 {
            return CategorySuggestion(category: poi.category, confidence: poi.confidence, source: .combined)
        }

        // Low POI confidence — fall back to time
        return CategorySuggestion(category: time.category, confidence: time.confidence, source: .combined)
    }
}
