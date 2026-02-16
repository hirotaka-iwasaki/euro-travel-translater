import XCTest

@MainActor
final class SnapshotTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITests"]
        setupSnapshot(app)
        app.launch()
    }

    // MARK: - Converter Tab

    func testCaptureConverterTab() {
        // Type "42.50" on the numpad
        app.buttons["numpad_4"].tap()
        app.buttons["numpad_2"].tap()
        app.buttons["numpad_dot"].tap()
        app.buttons["numpad_5"].tap()
        app.buttons["numpad_0"].tap()

        snapshot("01_Converter")
    }

    // MARK: - Expenses Tab

    func testCaptureExpensesTab() {
        app.buttons["tab_1"].tap()
        sleep(1)
        snapshot("02_Expenses")
    }

    // MARK: - Settings Tab

    func testCaptureSettingsTab() {
        app.buttons["tab_2"].tap()
        sleep(1)
        snapshot("03_Settings")
    }

    // MARK: - Record Expense Sheet

    func testCaptureRecordSheet() {
        // Enter an amount first
        app.buttons["numpad_1"].tap()
        app.buttons["numpad_5"].tap()

        // Tap the record button
        app.buttons["記録する"].tap()
        sleep(1)
        snapshot("04_RecordExpense")
    }
}
