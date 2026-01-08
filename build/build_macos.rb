#!/usr/bin/env ruby
# frozen_string_literal: true

# macOS .pkg 打包腳本
# 使用 Platypus 或 fpm

puts "開始打包 macOS .pkg 應用程式..."

# 建立 app bundle 目錄結構
app_name = "ScholarshipTools"
app_bundle = "build/#{app_name}.app"

FileUtils.mkdir_p("#{app_bundle}/Contents/MacOS")
FileUtils.mkdir_p("#{app_bundle}/Contents/Resources")

# 複製執行檔
FileUtils.cp("gui/main_window.rb", "#{app_bundle}/Contents/MacOS/#{app_name}")
FileUtils.chmod(0755, "#{app_bundle}/Contents/MacOS/#{app_name}")

# 建立 Info.plist
info_plist = <<~PLIST
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
  <plist version="1.0">
  <dict>
    <key>CFBundleExecutable</key>
    <string>#{app_name}</string>
    <key>CFBundleIdentifier</key>
    <string>com.scholarship.tools</string>
    <key>CFBundleName</key>
    <string>#{app_name}</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
  </dict>
  </plist>
PLIST

File.write("#{app_bundle}/Contents/Info.plist", info_plist)

puts "\n✓ App bundle 已建立："
puts "  #{app_bundle}"

# 建立 .pkg (需要 pkgbuild 工具)
if system("which pkgbuild > /dev/null")
  system("pkgbuild --root #{app_bundle} --install-location /Applications build/#{app_name}.pkg")
  puts "\n✓ .pkg 已建立："
  puts "  build/#{app_name}.pkg"
else
  puts "\n注意: 找不到 pkgbuild，僅建立 .app bundle"
end
