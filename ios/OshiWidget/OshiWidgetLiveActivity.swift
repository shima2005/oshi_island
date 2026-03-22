import ActivityKit
import WidgetKit
import SwiftUI

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
            
            let oshiName = sharedDefault?.string(forKey: prefix + "_oshiName") ?? "推し(代替)"
            let status = (sharedDefault != nil) ? "AppGroup: OK✅" : "AppGroup: NG❌"
            
            VStack(spacing: 8) {
                Text("🏝️ 生存確認 🏝️")
                    .font(.headline)
                Text("\(oshiName) (\(status))")
                    .font(.subheadline)
                Text("ID: \(prefix.prefix(4))")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding()
            
        } dynamicIsland: { context in
            let sharedDefault = UserDefaults(suiteName: context.state.appGroupId)
            let prefix = context.attributes.id.uuidString
            let oshiName = sharedDefault?.string(forKey: prefix + "_oshiName") ?? "推し(代替)"
            
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("左")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("右")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("生存確認: \(oshiName)")
                        .font(.caption)
                }
            } compactLeading: {
                Text("🐻")
            } compactTrailing: {
                Text("🚥")
            } minimal: {
                Text("🐻")
            }
        }
    }
}

@main
struct OshiWidgetBundle: WidgetBundle {
    var body: some Widget {
        OshiWidgetLiveActivity()
    }
}
