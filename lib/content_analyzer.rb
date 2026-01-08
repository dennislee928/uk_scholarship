# frozen_string_literal: true

# 內容分析模組
# 負責分析文件的可讀性、關鍵字密度、結構完整性等
class ContentAnalyzer
  # SDGs 相關關鍵字
  SDGS_KEYWORDS = {
    'SDG4_優質教育' => ['教育', '學習', '教學', '培訓', '知識', '技能', '教案', '工作坊', '分享'],
    'SDG3_良好健康' => ['健康', '福祉', '安全', '風險', '防護', '保護'],
    'SDG9_產業創新' => ['創新', '研發', '技術', '工程', '開發', '系統'],
    'SDG16_和平正義' => ['安全', '詐騙', '風險', '治理', '稽核', '合規'],
    'SDG17_夥伴關係' => ['合作', '社群', '分享', '貢獻', '開源', '回饋']
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

    content = File.read(file_path, encoding: 'utf-8')
    
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
  def analyze_project(base_path = '.')
    files_to_analyze = [
      File.join(base_path, '2025_明緯獎學金_李沛宸/01_申請書/300字短答_為何申請.md'),
      File.join(base_path, '2025_明緯獎學金_李沛宸/02_自傳與學習計畫/自傳.md'),
      File.join(base_path, '2025_明緯獎學金_李沛宸/02_自傳與學習計畫/短期學習計畫.md'),
      File.join(base_path, '2025_明緯獎學金_李沛宸/02_自傳與學習計畫/未來工作應用.md')
    ]

    existing_files = files_to_analyze.select { |f| File.exist?(f) }
    analyze_batch(existing_files)
  end

  # 生成分析摘要
  def summary
    return "尚未進行分析" if @analysis_results.empty?

    summary_text = "內容分析摘要\n"
    summary_text += "=" * 50 + "\n\n"

    @analysis_results.each do |file, analysis|
      summary_text += "\n檔案: #{File.basename(file)}\n"
      summary_text += "-" * 40 + "\n"
      summary_text += "可讀性評分: #{analysis[:readability][:score]}/100\n"
      summary_text += "結構完整性: #{analysis[:structure][:score]}/100\n"
      summary_text += "SDGs 對齊: #{analysis[:sdgs_alignment][:matched_sdgs].join(', ')}\n"
      summary_text += "常見錯誤: #{analysis[:common_errors][:count]} 個\n"
      summary_text += "\n"
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
    paragraphs = content.split(/\n\n+/)
    
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
    total_chars = text.gsub(/\s/, '').length

    # 重要關鍵字
    important_keywords = ['軟體', '工程', '開發', '安全', '資安', '系統', '專案', '技術']
    
    keyword_counts = important_keywords.map do |keyword|
      count = text.scan(keyword).length
      density = total_chars > 0 ? (count.to_f / total_chars * 1000).round(2) : 0
      [keyword, { count: count, density: density }]
    end.to_h

    {
      keywords: keyword_counts,
      top_keywords: keyword_counts.sort_by { |_k, v| -v[:count] }.first(5).to_h
    }
  end

  # 分析結構
  def analyze_structure(content)
    structure_checks = {
      has_title: content.match?(/^#\s+/),
      has_sections: content.scan(/^##\s+/).length > 0,
      has_lists: content.match?(/^[-*+]\s+/) || content.match?(/^\d+\.\s+/),
      section_count: content.scan(/^##\s+/).length
    }

    score = 0
    score += 30 if structure_checks[:has_title]
    score += 30 if structure_checks[:has_sections]
    score += 20 if structure_checks[:has_lists]
    score += 20 if structure_checks[:section_count] >= 3

    {
      score: score,
      checks: structure_checks,
      recommendation: generate_structure_recommendation(structure_checks)
    }
  end

  # 分析 SDGs 關鍵字
  def analyze_sdgs_keywords(content)
    text = remove_markdown(content)
    
    matched_sdgs = []
    sdg_details = {}

    SDGS_KEYWORDS.each do |sdg, keywords|
      matches = keywords.select { |keyword| text.include?(keyword) }
      
      if matches.any?
        matched_sdgs << sdg
        sdg_details[sdg] = {
          matched_keywords: matches,
          count: matches.length
        }
      end
    end

    {
      matched_sdgs: matched_sdgs,
      details: sdg_details,
      alignment_score: [100, matched_sdgs.length * 20].min
    }
  end

  # 偵測常見錯誤
  def detect_common_errors(content)
    errors = []

    # 檢查重複標點符號
    errors << "發現重複標點符號" if content.match?(/[。，！？]{2,}/)
    
    # 檢查全形/半形混用
    errors << "全形半形數字混用" if content.match?(/\d/) && content.match?(/[０-９]/)
    
    # 檢查多餘空格
    errors << "發現多餘空格" if content.match?(/\s{3,}/)
    
    # 檢查錯誤的引號使用
    errors << "引號使用不一致" if content.include?("「") && content.include?(""")

    {
      count: errors.length,
      errors: errors,
      has_errors: errors.any?
    }
  end

  # 計算統計資訊
  def calculate_statistics(content)
    text = remove_markdown(content)
    
    {
      total_characters: text.length,
      chinese_characters: text.scan(/[\u4e00-\u9fff]/).length,
      english_words: text.scan(/[a-zA-Z]+/).length,
      numbers: text.scan(/\d+/).length,
      punctuation: text.scan(/[，。！？、；：]/).length,
      lines: content.lines.count,
      paragraphs: content.split(/\n\n+/).length
    }
  end

  # 移除 Markdown 語法
  def remove_markdown(content)
    text = content.dup
    text.gsub!(/^#\{1,6\}\s+/, '')
    text.gsub!(/[*_]{1,2}([^*_]+)[*_]{1,2}/, '\1')
    text.gsub!(/\[([^\]]+)\]\([^)]+\)/, '\1')
    text.gsub!(/!\[([^\]]*)\]\([^)]+\)/, '')
    text.gsub!(/```[\s\S]*?```/, '')
    text.gsub!(/`([^`]+)`/, '\1')
    text.gsub!(/^[-*_]{3,}$/, '')
    text.gsub!(/^[\s]*[-*+]\s+/, '')
    text.gsub!(/^[\s]*\d+\.\s+/, '')
    text.gsub!(/^>\s+/, '')
    text.gsub!(/<[^>]+>/, '')
    text.strip
  end

  # 生成可讀性建議
  def generate_readability_recommendation(score)
    case score
    when 80..100
      "可讀性良好"
    when 60..79
      "可讀性中等，建議簡化部分長句"
    else
      "可讀性偏低，建議增加段落分隔並縮短句子"
    end
  end

  # 生成結構建議
  def generate_structure_recommendation(checks)
    recommendations = []
    recommendations << "建議加入標題" unless checks[:has_title]
    recommendations << "建議加入章節標題" unless checks[:has_sections]
    recommendations << "建議使用清單來組織內容" unless checks[:has_lists]
    
    recommendations.empty? ? "結構良好" : recommendations.join("；")
  end
end
