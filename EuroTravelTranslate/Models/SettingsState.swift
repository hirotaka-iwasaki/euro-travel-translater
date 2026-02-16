import Foundation
import SwiftData

@Model
final class SettingsState {
    var eurToJpyRate: Double = 160.0
    var tripStartDate: Date?

    init(
        eurToJpyRate: Double = 160.0,
        tripStartDate: Date? = nil
    ) {
        self.eurToJpyRate = eurToJpyRate
        self.tripStartDate = tripStartDate
    }
}
