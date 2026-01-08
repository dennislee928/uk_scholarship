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
