source 'https://rubygems.org'

# Markdown 解析與處理
gem 'kramdown', '~> 2.4'
gem 'kramdown-parser-gfm'

# PDF 生成與處理（純 Ruby，適合打包）
gem 'prawn', '~> 2.4'
gem 'prawn-table'
gem 'ttfunk'  # 字體支援
gem 'combine_pdf', '~> 1.0'

# GUI 框架（跨平台）
gem 'glimmer-dsl-libui', '~> 0.7'

# CLI 工具
gem 'colorize', '~> 1.1'
gem 'tty-prompt', '~> 0.23'
gem 'tty-progressbar', '~> 0.18'
gem 'tty-spinner', '~> 0.9'

# 測試框架
group :development, :test do
  gem 'rspec', '~> 3.12'
  gem 'rspec-mocks'
end

# 打包工具
group :build do
  gem 'ocra', '~> 1.3', platforms: :mingw  # Windows 打包
end

# 開發工具
group :development do
  gem 'rake', '~> 13.0'
  gem 'rubocop', '~> 1.50'
end

# 實用工具
gem 'fileutils'
gem 'json'
