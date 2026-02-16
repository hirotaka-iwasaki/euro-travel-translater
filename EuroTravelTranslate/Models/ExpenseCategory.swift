import SwiftUI

enum ExpenseCategory: String, Codable, CaseIterable, Sendable {
    case food
    case transport
    case shopping
    case accommodation
    case sightseeing
    case other

    var displayName: String {
        switch self {
        case .food: "食事"
        case .transport: "交通"
        case .shopping: "買物"
        case .accommodation: "宿泊"
        case .sightseeing: "観光"
        case .other: "その他"
        }
    }

    var icon: String {
        switch self {
        case .food: "fork.knife"
        case .transport: "tram.fill"
        case .shopping: "bag.fill"
        case .accommodation: "bed.double.fill"
        case .sightseeing: "ticket.fill"
        case .other: "ellipsis.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .food: Color(red: 0.88, green: 0.55, blue: 0.22)
        case .transport: Color(red: 0.02, green: 0.16, blue: 0.56)
        case .shopping: Color(red: 0.80, green: 0.18, blue: 0.24)
        case .accommodation: Color(red: 0.38, green: 0.28, blue: 0.62)
        case .sightseeing: Color(red: 0.24, green: 0.54, blue: 0.42)
        case .other: .gray
        }
    }
}
