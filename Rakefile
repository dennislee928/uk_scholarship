require 'rake'
require 'rspec/core/rake_task'

# 預設任務
task default: [:spec]

# 測試任務
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rspec_opts = ['--color', '--format', 'documentation']
end

# 驗證任務
desc "驗證所有文件"
task :validate do
  ruby 'scripts/cli.rb validate'
end

# 轉換任務
desc "轉換 Markdown 為 PDF"
task :convert do
  ruby 'scripts/cli.rb convert'
end

# 合併任務
desc "合併 PDF 檔案"
task :merge do
  ruby 'scripts/cli.rb merge'
end

# 分析任務
desc "分析內容品質"
task :analyze do
  ruby 'scripts/cli.rb analyze'
end

# 報告任務
desc "生成完整報告"
task :report do
  ruby 'scripts/cli.rb report'
end

# 完整流程
desc "執行完整流程：驗證、轉換、合併、分析、報告"
task :all do
  ruby 'scripts/cli.rb all'
end

# 建立目錄結構
desc "建立專案目錄結構"
task :setup do
  dirs = %w[lib gui gui/components gui/assets scripts spec build product]
  dirs.each do |dir|
    FileUtils.mkdir_p(dir)
    puts "建立目錄: #{dir}"
  end
  puts "目錄結構建立完成！"
end

# 清理任務
desc "清理生成的檔案"
task :clean do
  FileUtils.rm_rf('product/*.pdf')
  FileUtils.rm_rf('*.log')
  puts "清理完成！"
end
