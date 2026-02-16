import Foundation
import SwiftData

@Model
final class ExpenseItem {
    var id: UUID
    var createdAt: Date
    var euroAmount: Double
    var category: String
    var memo: String

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        euroAmount: Double,
        category: ExpenseCategory,
        memo: String = ""
    ) {
        self.id = id
        self.createdAt = createdAt
        self.euroAmount = euroAmount
        self.category = category.rawValue
        self.memo = memo
    }

    var expenseCategory: ExpenseCategory {
        ExpenseCategory(rawValue: category) ?? .other
    }
}
