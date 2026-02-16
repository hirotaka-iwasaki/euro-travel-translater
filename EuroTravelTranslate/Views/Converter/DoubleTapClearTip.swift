import SwiftUI
import TipKit

struct DoubleTapClearTip: Tip {
    static let firstInputEvent = Tips.Event(id: "firstInput")

    var title: Text { Text("ダブルタップでクリア") }
    var message: Text? { Text("金額表示をダブルタップすると\nゼロに戻せます") }
    var image: Image? { Image(systemName: "hand.tap") }

    var rules: [Tips.Rule] {
        #Rule(Self.firstInputEvent) { $0.donations.count >= 1 }
    }
}
