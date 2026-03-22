require 'xcodeproj'

project = Xcodeproj::Project.open('ios/Runner.xcodeproj')
target_name = 'OshiWidget'

# ⚠️ 先ほどと同じく、ExtensionのBundle IDを入れてください！
bundle_id = 'com.shima.oshiisland.DynamicIsland'

puts "島の開拓を開始します: #{target_name}"

target = project.new_target(:app_extension, target_name, :ios, '16.1')

group = project.main_group.find_subpath('OshiWidget') || project.main_group.new_group('OshiWidget', 'OshiWidget')
swift_file = group.files.find { |f| f.path == 'OshiWidgetLiveActivity.swift' } || group.new_file('OshiWidgetLiveActivity.swift')
plist_file = group.files.find { |f| f.path == 'Info.plist' } || group.new_file('Info.plist')
entitlements_file = group.files.find { |f| f.path == 'OshiWidget.entitlements' } || group.new_file('OshiWidget.entitlements')

target.add_file_references([swift_file])

target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = bundle_id
  config.build_settings['INFOPLIST_FILE'] = "OshiWidget/Info.plist"
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = "OshiWidget/OshiWidget.entitlements" # 🌟 通行証を追加！
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1'
  config.build_settings['DEVELOPMENT_TEAM'] = ENV['TEAM_ID'] || ''
  config.build_settings['CODE_SIGN_STYLE'] = 'Manual'
  config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ENV['WIDGET_PROFILE_UUID'] || ''
  config.build_settings['CODE_SIGN_IDENTITY'] = 'Apple Development'
end

runner_target = project.targets.find { |t| t.name == 'Runner' }
embed_phase = runner_target.copy_files_build_phases.find { |pb| pb.name == 'Embed Foundation Extensions' }
if embed_phase.nil?
  embed_phase = runner_target.new_copy_files_build_phase('Embed Foundation Extensions')
  embed_phase.symbol_dst_subfolder_spec = :plug_ins
end

unless embed_phase.files_references.include?(target.product_reference)
  build_file = embed_phase.add_file_reference(target.product_reference)
  build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
end

project.save
puts "✅ 島の開拓が完了しました！"