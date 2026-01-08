# frozen_string_literal: true

# 內容分析模組
# 負責分析文件的可讀性、關鍵字密度、結構完整性等
class ContentAnalyzer
  # SDGs 相關關鍵字
  SDGS_KEYWORDS = {
    SDG4_優質教育 => [教育, 學習, 教學, 培訓, 知識, 技能, 教案, 工作坊, 分享],
    SDG3_良好健康 => [健康, 福祉, 安全, 風險, 防護, 保護],
    SDG9_產業創新 => [創新, 研發, 技術, 工程, 開發, 系統],
    SDG16_和平正義 => [安全, 詐騙, 風險, 治理, 稽核, 合規],
  }.freeze

  attr_reader :analysis_results

  def initialize
    @analysis_results = {}
  end

  # 分析單一檔案
  def analyze_file(file_path)
    unless File.exist?(file_path)
      return { error: "檔案不存在: #{file_path}" }
    end

    content = File.read(file_path, encoding: utf-8)
    
    analysis = {
      file: file_path,
      readability: analyze_readability(content),
      keyword_density: analyze_keywords(content),
      structure: analyze_structure(content),
      sdgs_alignment: analyze_sdgs_keywords(content),
      common_errors: detect_common_errors(content),
      statistics: calculate_statistics(content)
    }

    @analysis_results[file_path] = analysis
    analysis
  end

  # 批次分析多個檔案
  def analyze_batch(file_paths)
    file_paths.each_with_index do |file_path, index|
      analyze_file(file_path)
      yield(index + 1, file_paths.length, file_path) if block_given?
    end
    
    @analysis_results
  end

  # 分析專案所有文件
  def analyze_project(base_path = .)
    files_to_analyze = [
      File.join(base_path, 2025_明緯獎學金_李沛宸/01_申請書/300字短答_為何申請.md),
      File.join(base_path, 2025_明緯獎學金_李沛宸/02_自傳與學習計畫/自傳.md),
      File.join(base_path, 2025_明緯獎學金_李沛宸/02_自傳與學習計畫/短期學習計畫.md),
      File.join(base_path, 2025_明緯獎學金_李沛宸/02_自傳與學習計畫/未來工作應用.md)
    ]

    existing_files = files_to_analyze.select { |f| File.exist?(f) }
    analyze_batch(existing_files)
  end

  # 生成分析摘要
  def summary
    return "尚未進行分析" if @analysis_results.empty?

    summary_text = "內容分析摘要
"
    summary_text += "=" * 50 + "

"

    @analysis_results.each do |file, analysis|
      summary_text += "
檔案: #{File.basename(file)}
"
      summary_text += "-" * 40 + "
"
      summary_text += "可讀性評分: #{analysis[:readability][:score]}/100
"
      summary_text += "結構完整性: #{analysis[:structure][:score]}/100
"
      summary_text += "SDGs 對齊: #{analysis[:sdgs_alignment][:matched_sdgs].join(, )}
"
      summary_text += "常見錯誤: #{analysis[:common_errors][:count]} 個
"
      summary_text += "
"
    end

    summary_text
  end

  private

  # 分析可讀性
  def analyze_readability(content)
    text = remove_markdown(content)
    
    # 計算平均句長
    sentences = text.split(/[。！？]/)
    avg_sentence_length = sentences.map(&:length).sum.to_f / sentences.length rescue 0
    
    # 計算段落數量
    paragraphs = content.split(/

+/)
    
    # 簡單的可讀性評分（0-100）
    score = 100
    score -= 20 if avg_sentence_length > 50  # 句子太長
    score -= 10 if paragraphs.length < 3     # 段落太少
    score = [0, score].max

    {
      score: score,
      avg_sentence_length: avg_sentence_length.round(1),
      paragraph_count: paragraphs.length,
      recommendation: generate_readability_recommendation(score)
    }
  end

  # 分析關鍵字密度
  def analyze_keywords(content)
    text = remove_markdown(content).downcase
