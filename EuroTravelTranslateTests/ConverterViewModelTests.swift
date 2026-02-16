import Testing
import Foundation
@testable import EuroTravelTranslate

@Suite("ConverterViewModel Tests")
struct ConverterViewModelTests {

    @MainActor
    private func makeViewModel(rate: Double = 160.0) -> ConverterViewModel {
        let vm = ConverterViewModel()
        vm.eurToJpyRate = rate
        return vm
    }

    @Test("Append digits builds input text")
    @MainActor
    func appendDigits() {
        let vm = makeViewModel()
        vm.appendDigit("2")
        vm.appendDigit("0")
        #expect(vm.inputText == "20")
        #expect(vm.eurAmount == 20.0)
        #expect(vm.jpyAmount == 3200.0)
    }

    @Test("Append dot adds decimal point")
    @MainActor
    func appendDot() {
        let vm = makeViewModel()
        vm.appendDigit("5")
        vm.appendDot()
        vm.appendDigit("5")
        vm.appendDigit("0")
        #expect(vm.inputText == "5.50")
        #expect(vm.eurAmount == 5.5)
    }

    @Test("Cannot append two dots")
    @MainActor
    func doubleDot() {
        let vm = makeViewModel()
        vm.appendDigit("5")
        vm.appendDot()
        vm.appendDot()
        #expect(vm.inputText == "5.")
    }

    @Test("Limits decimal places to 2")
    @MainActor
    func decimalLimit() {
        let vm = makeViewModel()
        vm.appendDigit("1")
        vm.appendDot()
        vm.appendDigit("2")
        vm.appendDigit("3")
        vm.appendDigit("4")  // Should be ignored
        #expect(vm.inputText == "1.23")
    }

    @Test("Delete last removes character")
    @MainActor
    func deleteLast() {
        let vm = makeViewModel()
        vm.appendDigit("1")
        vm.appendDigit("2")
        vm.deleteLast()
        #expect(vm.inputText == "1")
        #expect(vm.eurAmount == 1.0)
    }

    @Test("Delete on empty does nothing")
    @MainActor
    func deleteEmpty() {
        let vm = makeViewModel()
        vm.deleteLast()
        #expect(vm.inputText == "")
    }

    @Test("Set amount from quick grid")
    @MainActor
    func setAmount() {
        let vm = makeViewModel()
        vm.setAmount(50)
        #expect(vm.inputText == "50")
        #expect(vm.eurAmount == 50.0)
        #expect(vm.jpyAmount == 8000.0)
    }

    @Test("Clear resets all values")
    @MainActor
    func clear() {
        let vm = makeViewModel()
        vm.appendDigit("5")
        vm.clear()
        #expect(vm.inputText == "")
        #expect(vm.eurAmount == 0)
        #expect(vm.jpyAmount == 0)
    }

    @Test("Conversion uses custom rate")
    @MainActor
    func customRate() {
        let vm = makeViewModel(rate: 170.0)
        vm.appendDigit("1")
        vm.appendDigit("0")
        #expect(vm.jpyAmount == 1700.0)
    }

    @Test("Leading zero replaced by digit")
    @MainActor
    func leadingZero() {
        let vm = makeViewModel()
        vm.appendDigit("0")
        vm.appendDigit("5")
        #expect(vm.inputText == "5")
    }

    @Test("Dot on empty starts with 0.")
    @MainActor
    func dotOnEmpty() {
        let vm = makeViewModel()
        vm.appendDot()
        #expect(vm.inputText == "0.")
    }
}
