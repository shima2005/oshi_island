import ActivityKit
import WidgetKit
import SwiftUI

// 1. データの定義（Flutterから島に渡すデータ）
struct OshiWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // 動的に変わるデータ（例：Flutterから更新されるメッセージなど）
        var message: String
    }
    // 固定のデータ（例：推しの名前）
    var oshiName: String
}

// 2. 島の見た目（UI）の定義
struct OshiWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: OshiWidgetAttributes.self) { context in
            // ロック画面に表示される大きなUI
            VStack {
                Text("\(context.attributes.oshiName)が島にいます🏝️")
                    .font(.headline)
                Text(context.state.message)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
        } dynamicIsland: { context in
            // ダイナミックアイランドのUI定義
            DynamicIsland {
                // ① 長押しされて広がった時 (Expanded)
                DynamicIslandExpandedRegion(.leading) {
                    Text("🐻") // 左側にダッフィー風のアイコン
                        .font(.title2)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.attributes.oshiName) // 右側に名前
                        .font(.caption)
                        .padding(.top, 8)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.message) // 下部にメッセージ
                        .font(.caption)
                }
            } compactLeading: {
                // ② 通常時・左側 (Compact Leading)
                Text("🐻")
            } compactTrailing: {
                // ③ 通常時・右側 (Compact Trailing)
                Text("🏝️")
            } minimal: {
                // ④ 最小化時（他のアプリも島を使っている時）
                Text("🐻")
            }
        }
    }
}

// 3. ウィジェットの起動ポイント（おまじない）
@main
struct OshiWidgetBundle: WidgetBundle {
    var body: some Widget {
        OshiWidgetLiveActivity()
    }
}