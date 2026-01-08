# frozen_string_literal: true

require fileutils

# 文件驗證模組
# 負責檢查文件字數、格式、完整性等
class DocumentValidator
  # 字數限制配置
  WORD_LIMITS = {
    300字短答_為何申請.md => 300,
    自傳.md => 800,
    短期學習計畫.md => 800,
    未來工作應用.md => 1000
  }.freeze

  attr_reader :results

  def initialize
    @results = []
  end

  # 驗證單一檔案
  def validate_file(file_path, word_limit = nil)
    unless File.exist?(file_path)
      return build_result(file_path, false, "檔案不存在", word_limit: word_limit)
    end

    content = File.read(file_path, encoding: utf-8)
    
    # 移除 Markdown 語法計算實際字數
    text = remove_markdown_syntax(content)
    word_count = count_chinese_characters(text)

    # 確定字數限制
    limit = word_limit || guess_word_limit(File.basename(file_path))

    # 執行各項檢查
    checks = {
      word_count_valid: validate_word_count(word_count, limit),
      markdown_valid: validate_markdown_format(content),
      has_title: validate_has_title(content),
      chinese_only: validate_chinese_content(text),
      no_special_chars: validate_special_characters(text)
    }

    all_valid = checks.values.all?
    messages = build_check_messages(checks, word_count, limit)

    build_result(
      file_path,
      all_valid,
      messages.join("
"),
      word_count: word_count,
      word_limit: limit,
      checks: checks
    )
  end

  # 批次驗證多個檔案
  def validate_batch(file_paths)
    @results = file_paths.map { |path| validate_file(path) }
    @results
  end

  # 驗證專案所有文件
  def validate_project(base_path = .)
    files_to_validate = [
      File.join(base_path, 2025_明緯獎學金_李沛宸/01_申請書/300字短答_為何申請.md),
      File.join(base_path, 2025_明緯獎學金_李沛宸/02_自傳與學習計畫/自傳.md),
      File.join(base_path, 2025_明緯獎學金_李沛宸/02_自傳與學習計畫/短期學習計畫.md),
      File.join(base_path, 2025_明緯獎學金_李沛宸/02_自傳與學習計畫/未來工作應用.md)
    ]

    validate_batch(files_to_validate)
  end

  # 生成驗證摘要
  def summary
    return "尚未進行驗證" if @results.empty?

    total = @results.length
    passed = @results.count { |r| r[:valid] }
    failed = total - passed

    summary_text = "驗證摘要
"
    summary_text += "=" * 50 + "
"
    summary_text += "總計: #{total} 個檔案
"
    summary_text += "失敗: #{failed} 個
"
    summary_text += "通過率: #{(passed * 100.0 / total).round(2)}%
"
    summary_text += "
"

    @results.each do |result|
      status = result[:valid] ? "✓" : "✗"
      summary_text += "#{status} #{File.basename(result[:file])}
"
      summary_text += "   #{result[:message]}
" unless result[:message].empty?
    end

    summary_text
  end

  private

  # 移除 Markdown 語法
  def remove_markdown_syntax(content)
    text = content.dup
    
    # 移除標題標記
    text.gsub!(/^#\{1,6}\s+/, )
    
    # 移除粗體、斜體
    text.gsub!(/[*_]{1,2}([^*_]+)[*_]{1,2}/, \1)
    
    # 移除連結
    text.gsub!(/\[([^\]]+)\]\([^)]+\)/, \1)
    
    # 移除圖片
    text.gsub!(/!\[([^\]]*)\]\([^)]+\)/, )
    
    # 移除程式碼區塊
    text.gsub!(/```[\s\S]*?```/, )
    text.gsub!(/`([^`]+)`/, \1)
    
    # 移除分隔線
    text.gsub!(/^[-*_]{3,}$/, )
    
    # 移除清單標記
    text.gsub!(/^[\s]*[-*+]\s+/, )
    text.gsub!(/^[\s]*\d+\.\s+/, )
    
    # 移除引用標記
    text.gsub!(/^>\s+/, )
    
    # 移除 HTML 標籤
    text.gsub!(/<[^>]+>/, )
    
    # 移除多餘空白
    text.gsub!(/\s+/,  )
    text.strip
  end

  # 計算中文字數（包含標點符號）
  def count_chinese_characters(text)
    # 移除英文字母、數字和空格後計算
    chinese_text = text.gsub(/[a-zA-Z0-9\s]/, )
    chinese_text.length
  end

  # 驗證字數是否符合限制
  def validate_word_count(word_count, limit)
    return true if limit.nil?
    word_count <= limit
  end

  # 驗證 Markdown 格式
  def validate_markdown_format(content)
    # 檢查是否有標題
    content.match?(/^#\s+.+/)
  end

  # 驗證是否有標題
  def validate_has_title(content)
    content.match?(/^#\s+.+/)
  end

  # 驗證內容是否為繁體中文
  def validate_chinese_content(text)
    # 簡單檢查：確保主要內容是中文
    chinese_chars = text.scan(/[\u4e00-\u9fff]/).length
