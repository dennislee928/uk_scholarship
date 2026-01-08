#!/usr/bin/env ruby
# frozen_string_literal: true

# Windows .exe 打包腳本
# 使用 OCRA (One-Click Ruby Application)

puts "開始打包 Windows .exe 應用程式..."

# 檢查 OCRA 是否已安裝
unless system("ocra --version")
  puts "錯誤: 找不到 OCRA。請先安裝: gem install ocra"
  exit 1
end

# 打包 CLI 應用
puts "\n打包 CLI 應用..."
system("ocra scripts/cli.rb --output build/scholarship-cli.exe --gem-full --add-all-core --windows")

# 打包 GUI 應用
puts "\n打包 GUI 應用..."
system("ocra gui/main_window.rb --output build/scholarship-gui.exe --gem-full --add-all-core --windows")

puts "\n✓ 打包完成！"
puts "輸出檔案："
puts "  - build/scholarship-cli.exe"
puts "  - build/scholarship-gui.exe"
