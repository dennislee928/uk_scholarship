# frozen_string_literal: true

require 'fileutils'

# 檢查清單驗證模組
# 負責解析和驗證 README.md 中的檢查清單
class ChecklistValidator
  attr_reader :checklist_items, :validation_results

  def initialize(readme_path = nil)
    @readme_path = readme_path || find_readme_path
    @checklist_items = []
    @validation_results = []
  end

  # 解析 README 中的檢查清單
  def parse_checklist
    unless File.exist?(@readme_path)
      raise "找不到 README 檔案: #{@readme_path}"
    end

    content = File.read(@readme_path, encoding: 'utf-8')
    @checklist_items = extract_checklist_items(content)
    @checklist_items
  end

  # 驗證檢查清單項目
  def validate
    parse_checklist if @checklist_items.empty?

    @validation_results = @checklist_items.map do |item|
      validate_item(item)
    end

    @validation_results
  end

  # 生成驗證報告
  def generate_report
    validate if @validation_results.empty?

    total = @validation_results.length
    completed = @validation_results.count { |r| r[:status] == :completed }
    pending = total - completed

    report = "檢查清單驗證報告\n"
    report += "=" * 50 + "\n\n"
    report += "總計項目: #{total}\n"
    report += "已完成: #{completed}\n"
    report += "待完成: #{pending}\n"
    report += "完成率: #{(completed * 100.0 / total).round(2)}%\n\n"

    # 按類別分組
    @validation_results.group_by { |r| r[:category] }.each do |category, items|
      report += "\n### #{category}\n"
      items.each do |item|
        status_icon = item[:status] == :completed ? '✓' : '☐'
        report += "#{status_icon} #{item[:description]}\n"
        report += "   #{item[:validation_message]}\n" if item[:validation_message]
      end
    end

    report
  end

  # 取得未完成的項目
  def pending_items
    @validation_results.select { |r| r[:status] == :pending }
  end

  # 取得已完成的項目
  def completed_items
    @validation_results.select { |r| r[:status] == :completed }
  end

  # 計算完成百分比
  def completion_percentage
    return 0 if @validation_results.empty?
    
    completed = @validation_results.count { |r| r[:status] == :completed }
    (completed * 100.0 / @validation_results.length).round(2)
  end

  private

  # 尋找 README 檔案
  def find_readme_path
    possible_paths = [
      '2025_明緯獎學金_李沛宸/README.md',
      'README.md',
      '../README.md'
    ]

    possible_paths.find { |path| File.exist?(path) } || '2025_明緯獎學金_李沛宸/README.md'
  end

  # 提取檢查清單項目
  def extract_checklist_items(content)
    items = []
    current_category = "一般"
    in_checklist_section = false

    content.each_line do |line|
      # 偵測類別標題
      if line.match?(/^###\s+(.+)/)
        current_category = line.match(/^###\s+(.+)/)[1].strip
        in_checklist_section = true
        next
      end

      # 提取檢查清單項目
      if match = line.match(/^-\s+\[([ x])\]\s+(.+)/)
        checked = match[1] == 'x'
        description = match[2].strip
        
        items << {
          category: current_category,
          description: description,
          checked: checked,
          raw_line: line.strip
        }
      end
    end

    items
  end

  # 驗證單一項目
  def validate_item(item)
    validation = {
      category: item[:category],
      description: item[:description],
      status: item[:checked] ? :completed : :pending,
      validation_message: nil
    }

    # 根據項目描述進行實際驗證
    case item[:description]
    when /(\d+)\s*字短答/
      validation.merge!(validate_word_count_file('300字短答_為何申請.md', 300))
    when /自傳/
      validation.merge!(validate_file_exists('自傳.md'))
    when /短期學習計畫/
      validation.merge!(validate_file_exists('短期學習計畫.md'))
    when /未來工作應用/
      validation.merge!(validate_file_exists('未來工作應用.md'))
    when /PDF.*合併/
      validation.merge!(validate_merged_pdf)
    when /影片.*錄製/
      validation.merge!(validate_video_file)
    end

    validation
  end

  # 驗證檔案是否存在
  def validate_file_exists(filename)
    search_paths = [
      "2025_明緯獎學金_李沛宸/01_申請書/#{filename}",
      "2025_明緯獎學金_李沛宸/02_自傳與學習計畫/#{filename}",
      "2025_明緯獎學金_李沛宸/05_影片/#{filename}"
    ]

    file_exists = search_paths.any? { |path| File.exist?(path) }
    
    {
      status: file_exists ? :completed : :pending,
      validation_message: file_exists ? "檔案存在" : "找不到檔案"
    }
  end

  # 驗證字數
  def validate_word_count_file(filename, limit)
    file_path = Dir.glob("2025_明緯獎學金_李沛宸/**/#{filename}").first
    
    unless file_path && File.exist?(file_path)
      return {
        status: :pending,
        validation_message: "檔案不存在"
      }
    end

    content = File.read(file_path, encoding: 'utf-8')
    word_count = content.gsub(/[^[\u4e00-\u9fff]]/, '').length

    {
      status: word_count <= limit ? :completed : :pending,
      validation_message: "字數: #{word_count}/#{limit}"
    }
  end

  # 驗證合併的 PDF
  def validate_merged_pdf
    pdf_path = 'product/2025 明緯獎學金-李沛宸.pdf'
    
    {
      status: File.exist?(pdf_path) ? :completed : :pending,
      validation_message: File.exist?(pdf_path) ? "PDF 已生成" : "尚未生成 PDF"
    }
  end

  # 驗證影片檔案
  def validate_video_file
    video_patterns = ['*.mp4', '*.mov', '*.avi']
    video_dir = '2025_明緯獎學金_李沛宸/05_影片'
    
    video_files = video_patterns.flat_map { |pattern| Dir.glob(File.join(video_dir, pattern)) }
    
    {
      status: video_files.any? ? :completed : :pending,
      validation_message: video_files.any? ? "找到影片檔案" : "尚未錄製影片"
    }
  end
end
