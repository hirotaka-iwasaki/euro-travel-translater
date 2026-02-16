import Testing
import Foundation
@testable import EuroTravelTranslate

@Suite("ExpenseCategory Tests")
struct ExpenseCategoryTests {

    @Test("All categories have displayName")
    func displayNames() {
        let expected: [ExpenseCategory: String] = [
            .food: "食事",
            .transport: "交通",
            .shopping: "買物",
            .accommodation: "宿泊",
            .sightseeing: "観光",
            .other: "その他",
        ]
        for (category, name) in expected {
            #expect(category.displayName == name)
        }
    }

    @Test("All categories have icon")
    func icons() {
        let expected: [ExpenseCategory: String] = [
            .food: "fork.knife",
            .transport: "tram.fill",
            .shopping: "bag.fill",
            .accommodation: "bed.double.fill",
            .sightseeing: "ticket.fill",
            .other: "ellipsis.circle.fill",
        ]
        for (category, icon) in expected {
            #expect(category.icon == icon)
        }
    }

    @Test("CaseIterable has 6 cases")
    func caseCount() {
        #expect(ExpenseCategory.allCases.count == 6)
    }
}

@Suite("CategorySuggester Tests")
struct CategorySuggesterTests {
    let suggester = CategorySuggester()

    private func date(hour: Int) -> Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 2
        components.day = 15
        components.hour = hour
        components.minute = 0
        return Calendar.current.date(from: components)!
    }

    @Test("Suggests food for breakfast hours 7-9")
    func breakfast() {
        #expect(suggester.suggest(at: date(hour: 7)) == .food)
        #expect(suggester.suggest(at: date(hour: 9)) == .food)
    }

    @Test("Suggests food for lunch hours 11-13")
    func lunch() {
        #expect(suggester.suggest(at: date(hour: 11)) == .food)
        #expect(suggester.suggest(at: date(hour: 13)) == .food)
    }

    @Test("Suggests food for dinner hours 17-20")
    func dinner() {
        #expect(suggester.suggest(at: date(hour: 17)) == .food)
        #expect(suggester.suggest(at: date(hour: 20)) == .food)
    }

    @Test("Suggests other for non-meal hours")
    func nonMeal() {
        #expect(suggester.suggest(at: date(hour: 6)) == .other)
        #expect(suggester.suggest(at: date(hour: 10)) == .other)
        #expect(suggester.suggest(at: date(hour: 15)) == .other)
        #expect(suggester.suggest(at: date(hour: 22)) == .other)
    }
}
