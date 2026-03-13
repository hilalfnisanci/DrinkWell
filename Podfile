platform :ios, '18.0'

target 'DrinkWell' do
  platform :ios, '18.0'
  use_frameworks!
  
  # Pods for DrinkWell
  pod 'Google-Mobile-Ads-SDK'

  target 'DrinkWellTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'DrinkWellUITests' do
    # Pods for testing
  end

end

target 'DrinkWellWidgetExtension' do
  platform :ios, '18.0'
  use_frameworks!

  # Pods for DrinkWellWidgetExtension

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete('ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES')
      config.build_settings.delete('EMBEDDED_CONTENT_CONTAINS_SWIFT')
    end
  end

  Dir.glob('Pods/Target Support Files/**/*.xcconfig').each do |xcconfig_path|
    content = File.read(xcconfig_path)
    content = content.gsub(/^ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES\s*=\s*.*\n/, '')
    content = content.gsub(/^EMBEDDED_CONTENT_CONTAINS_SWIFT\s*=\s*.*\n/, '')
    File.write(xcconfig_path, content)
  end
end
