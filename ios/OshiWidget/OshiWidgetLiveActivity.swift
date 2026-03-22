import ActivityKit
import WidgetKit
import SwiftUI

// live_activities パッケージが要求するデータ構造
struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
    public typealias LiveDeliveryData = ContentState

    public struct ContentState: Codable, Hashable {
        var appGroupId: String
    }

    var id = UUID()
}

struct OshiWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            // ロック画面に表示される大きなUI
            let sharedDefault = UserDefaults(suiteName: context.state.appGroupId)
            let prefix = context.attributes.id.uuidString
            let oshiName = sharedDefault?.string(forKey: prefix + "_oshiName") ?? "推し"
            let message = sharedDefault?.string(forKey: prefix + "_message") ?? ""
            let endTime = sharedDefault?.double(forKey: prefix + "_endTime") ?? 0
            
            VStack {
                Text("\(oshiName)が島にいます🏝️")
                    .font(.headline)
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                if endTime > 0 {
                    Text(timerInterval: Date()...Date(timeIntervalSince1970: endTime))
                        .multilineTextAlignment(.center)
                        .monospacedDigit()
                        .font(.headline)
                }
            }
            .padding()
        } dynamicIsland: { context in
            let sharedDefault = UserDefaults(suiteName: context.state.appGroupId)
            let prefix = context.attributes.id.uuidString
            let oshiName = sharedDefault?.string(forKey: prefix + "_oshiName") ?? "推し"
            let message = sharedDefault?.string(forKey: prefix + "_message") ?? ""
            let endTime = sharedDefault?.double(forKey: prefix + "_endTime") ?? 0

            // ダイナミックアイランドのUI定義
            return DynamicIsland {
                // ① 長押しされて広がった時 (Expanded)
                DynamicIslandExpandedRegion(.leading) {
                    Text("🐻") // 左側にダッフィー風のアイコン
                        .font(.title2)
                        .padding(.leading, 8)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(oshiName) // 右側に名前
                        .font(.caption)
                        .padding(.top, 8)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack {
                        Text(message) // 下部にメッセージ
                            .font(.caption)
                        if endTime > 0 {
                            Text(timerInterval: Date()...Date(timeIntervalSince1970: endTime))
                                .multilineTextAlignment(.center)
                                .monospacedDigit()
                                .font(.headline)
                        }
                    }
                }
            } compactLeading: {
                // ② 通常時・左側 (Compact Leading)
                Text("🐻")
            } compactTrailing: {
                // ③ 通常時・右側 (Compact Trailing)
                if endTime > 0 {
                    Text(timerInterval: Date()...Date(timeIntervalSince1970: endTime))
                        .monospacedDigit()
                        .frame(maxWidth: 40)
                        .font(.caption2)
                } else {
                    Text("🏝️")
                }
            } minimal: {
                // ④ 最小化時（他のアプリも島を使っている時）
                Text("🐻")
            }
        }
    }
}

// 3. ウィジェットの起動ポイント
@main
struct OshiWidgetBundle: WidgetBundle {
    var body: some Widget {
        OshiWidgetLiveActivity()
    }
}
