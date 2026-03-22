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

// 共通のUIコンポーネント（画像を読み込む）
struct OshiAvatar: View {
    let imagePath: String?
    
    var body: some View {
        if let path = imagePath, let uiImage = UIImage(contentsOfFile: path) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
        } else {
            Text("🐻")
                .font(.title2)
        }
    }
}

// Compact用の小さなアバター
struct CompactOshiAvatar: View {
    let imagePath: String?
    
    var body: some View {
        if let path = imagePath, let uiImage = UIImage(contentsOfFile: path) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 24, height: 24)
                .clipShape(Circle())
        } else {
            Text("🐻")
        }
    }
}

struct OshiWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            // ロック画面に表示される大きなUI
            let sharedDefault = UserDefaults(suiteName: context.state.appGroupId)
            let prefix = context.attributes.id.uuidString
            let oshiName = sharedDefault?.string(forKey: prefix + "_oshiName") ?? "推し"
            let message = sharedDefault?.string(forKey: prefix + "_message") ?? ""
            let startTime = sharedDefault?.double(forKey: prefix + "_startTime") ?? Date().timeIntervalSince1970
            let endTime = sharedDefault?.double(forKey: prefix + "_endTime") ?? 0
            let imagePath = sharedDefault?.string(forKey: prefix + "_image")
            
            let startDate = Date(timeIntervalSince1970: startTime)
            let endDate = Date(timeIntervalSince1970: endTime)
            
            HStack(spacing: 16) {
                OshiAvatar(imagePath: imagePath)
                
                VStack(alignment: .leading) {
                    Text("\(oshiName)が島にいます🏝️")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // 🌟 Date()... の Range で lowerBound > upperBound になるとクラッシュするのを防ぐ
                if endTime > 0 && startDate < endDate {
                    Text(timerInterval: startDate...endDate)
                        .multilineTextAlignment(.center)
                        .monospacedDigit()
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color.black.opacity(0.8)) // 念のため背景を明示
        } dynamicIsland: { context in
            let sharedDefault = UserDefaults(suiteName: context.state.appGroupId)
            let prefix = context.attributes.id.uuidString
            let oshiName = sharedDefault?.string(forKey: prefix + "_oshiName") ?? "推し"
            let message = sharedDefault?.string(forKey: prefix + "_message") ?? ""
            let startTime = sharedDefault?.double(forKey: prefix + "_startTime") ?? Date().timeIntervalSince1970
            let endTime = sharedDefault?.double(forKey: prefix + "_endTime") ?? 0
            let imagePath = sharedDefault?.string(forKey: prefix + "_image")
            
            let startDate = Date(timeIntervalSince1970: startTime)
            let endDate = Date(timeIntervalSince1970: endTime)

            // ダイナミックアイランドのUI定義
            return DynamicIsland {
                // ① 長押しされて広がった時 (Expanded)
                DynamicIslandExpandedRegion(.leading) {
                    OshiAvatar(imagePath: imagePath)
                        .padding(.leading, 8)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(oshiName) // 右側に名前
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.top, 8)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack {
                        Text(message) // 下部にメッセージ
                            .font(.caption)
                            .foregroundColor(.gray)
                        if endTime > 0 && startDate < endDate {
                            Text(timerInterval: startDate...endDate)
                                .multilineTextAlignment(.center)
                                .monospacedDigit()
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                }
            } compactLeading: {
                // ② 通常時・左側 (Compact Leading)
                CompactOshiAvatar(imagePath: imagePath)
            } compactTrailing: {
                // ③ 通常時・右側 (Compact Trailing)
                if endTime > 0 && startDate < endDate {
                    Text(timerInterval: startDate...endDate)
                        .monospacedDigit()
                        .frame(maxWidth: 40)
                        .font(.caption2)
                        .foregroundColor(.white)
                } else {
                    Text("🏝️")
                }
            } minimal: {
                // ④ 最小化時（他のアプリも島を使っている時）
                CompactOshiAvatar(imagePath: imagePath)
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
