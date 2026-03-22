require 'xcodeproj'

project = Xcodeproj::Project.open('ios/Runner.xcodeproj')
target_name = 'OshiWidget'

# ⚠️ あなたの正しいBundle IDであることを確認してください
bundle_id = 'com.shima.oshiisland.DynamicIsland' 

puts "島の再開拓とサイクルエラーの修正を開始します: #{target_name}"

# 1. 重複エラー防止：既存のターゲットを一旦削除してクリーンにする
existing_target = project.targets.find { |t| t.name == target_name }
if existing_target
  existing_target.remove_from_project
end

# 2. ターゲットの作成
target = project.new_target(:app_extension, target_name, :ios, '16.1')

# 3. フォルダとファイルの登録
group = project.main_group.find_subpath('OshiWidget') || project.main_group.new_group('OshiWidget', 'OshiWidget')
swift_file = group.files.find { |f| f.path == 'OshiWidgetLiveActivity.swift' } || group.new_file('OshiWidgetLiveActivity.swift')
plist_file = group.files.find { |f| f.path == 'Info.plist' } || group.new_file('Info.plist')
entitlements_file = group.files.find { |f| f.path == 'OshiWidget.entitlements' } || group.new_file('OshiWidget.entitlements')

target.add_file_references([swift_file])

# 4. ビルド設定
target.build_configurations.each do |config|
  config.build_settings['PRODUCT_NAME'] = target_name
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = bundle_id
  config.build_settings['INFOPLIST_FILE'] = "OshiWidget/Info.plist"
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = "Runner/Runner.entitlements"
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = "OshiWidget/OshiWidget.entitlements"
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1'
  config.build_settings['DEVELOPMENT_TEAM'] = ENV['TEAM_ID'] || 'YOUR_TEAM_ID' # 安全のためプレースホルダーに変更
  config.build_settings['CODE_SIGN_STYLE'] = 'Manual'
  config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ENV['WIDGET_PROFILE_UUID'] || ''
  config.build_settings['CODE_SIGN_IDENTITY'] = 'Apple Development'
end

# 5. メインアプリ（Runner）側の設定
runner_target = project.targets.find { |t| t.name == 'Runner' }

# 🌟 依存関係の追加：島を先にビルドしてからメインアプリを作るように明示
unless runner_target.dependencies.any? { |d| d.target.name == target_name }
  runner_target.add_dependency(target)
end

# 6. 島を埋め込むフェーズの作成と「最背面」への移動
embed_phase = runner_target.copy_files_build_phases.find { |pb| pb.name == 'Embed Foundation Extensions' }
if embed_phase.nil?
  embed_phase = runner_target.new_copy_files_build_phase('Embed Foundation Extensions')
  embed_phase.symbol_dst_subfolder_spec = :plug_ins
end

unless embed_phase.files_references.include?(target.product_reference)
  build_file = embed_phase.add_file_reference(target.product_reference)
  build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy', 'CodeSignOnCopy'] }
end

# 🌟 サイクルエラー対策：Embedフェーズをビルド順序の「最後」に移動
runner_target.build_phases.delete(embed_phase)
runner_target.build_phases.push(embed_phase)

project.save
puts "✅ 修正が完了しました！これでサイクルエラーを回避できるはずです。"