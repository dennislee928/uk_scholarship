File.write('/Users/lipeichen/Documents/Untitled/uk_scholarship/lib/content_analyzer.rb', <<~RUBY)
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

    @analysis_results[file_path] = analysis\n    analysis\n  end\n\n  # 批次分析多個檔案\n  def analyze_batch(file_paths)\n    file_paths.each_with_index do |file_path, index|\n      analyze_file(file_path)\n      yield(index + 1, file_paths.length, file_path) if block_given?\n    end\n    \n    @analysis_results\n  end\n\n  # 分析專案所有文件\n  def analyze_project(base_path = '.')\n    files_to_analyze = [\n      File.join(base_path, '2025_明緯獎學金_李沛宸/01_申請書/300字短答_為何申請.md'),\n      File.join(base_path, '2025_明緯獎學金_李沛宸/02_自傳與學習計畫/自傳.md'),\n      File.join(base_path, '2025_明緯獎學金_李沛宸/02_自傳與學習計畫/短期學習計畫.md'),\n      File.join(base_path, '2025_明緯獎學金_李沛宸/02_自傳與學習計畫/未來工作應用.md')\n    ]\n\n    existing_files = files_to_analyze.select { |f| File.exist?(f) }\n    analyze_batch(existing_files)\n  end\n\n  # 生成分析摘要\n  def summary\n    return \"尚未進行分析\" if @analysis_results.empty?\n\n    summary_text = \"內容分析摘要\\n\"\n    summary_text += \"=\" * 50 + \"\\n\\n\"\n\n    @analysis_results.each do |file, analysis|\n      summary_text += \"\\n檔案: \#{File.basename(file)}\\n\"\n      summary_text += \"-\" * 40 + \"\\n\"\n      summary_text += \"可讀性評分: \#{analysis[:readability][:score]}/100\\n\"\n      summary_text += \"結構完整性: \#{analysis[:structure][:score]}/100\\n\"\n      summary_text += \"SDGs 對齊: \#{analysis[:sdgs_alignment][:matched_sdgs].join(', ')}\\n\"\n      summary_text += \"常見錯誤: \#{analysis[:common_errors][:count]} 個\\n\"\n      summary_text += \"\\n\"\n    end\n\n    summary_text\n  end\n\n  private\n\n  # 分析可讀性\n  def analyze_readability(content)\n    text = remove_markdown(content)\n    \n    # 計算平均句長\n    sentences = text.split(/[。！？]/)\n    avg_sentence_length = sentences.map(&:length).sum.to_f / sentences.length rescue 0\n    \n    # 計算段落數量\n    paragraphs = content.split(/\\n\\n+/)\n    \n    # 簡單的可讀性評分（0-100）\n    score = 100\n    score -= 20 if avg_sentence_length > 50  # 句子太長\n    score -= 10 if paragraphs.length < 3     # 段落太少\n    score = [0, score].max\n\n    {\n      score: score,\n      avg_sentence_length: avg_sentence_length.round(1),\n      paragraph_count: paragraphs.length,\n      recommendation: generate_readability_recommendation(score)\n    }\n  end\n\n  # 分析關鍵字密度\n  def analyze_keywords(content)\n    text = remove_markdown(content).downcase\n    total_chars = text.gsub(/\\\\s/, '').length\n\n    # 重要關鍵字\n    important_keywords = ['軟體', '工程', '開發', '安全', '資安', '系統', '專案', '技術']\n    \n    keyword_counts = important_keywords.map do |keyword|\n      count = text.scan(keyword).length\n      density = total_chars > 0 ? (count.to_f / total_chars * 1000).round(2) : 0\n      [keyword, { count: count, density: density }]\n    end.to_h\n\n    {\n      keywords: keyword_counts,\n      top_keywords: keyword_counts.sort_by { |_k, v| -v[:count] }.first(5).to_h\n    }\n  end\n\n  # 分析結構\n  def analyze_structure(content)\n    structure_checks = {\n      has_title: content.match?(/^#\\\\s+/),\n      has_sections: content.scan(/^##\\\\s+/).length > 0,\n      has_lists: content.match?(/^[-*+]\\\\s+/) || content.match?(/^\\\\d+\\\\.\\\\s+/),\n      section_count: content.scan(/^##\\\\s+/).length\n    }\n\n    score = 0\n    score += 30 if structure_checks[:has_title]\n    score += 30 if structure_checks[:has_sections]\n    score += 20 if structure_checks[:has_lists]\n    score += 20 if structure_checks[:section_count] >= 3\n\n    {\n      score: score,\n      checks: structure_checks,\n      recommendation: generate_structure_recommendation(structure_checks)\n    }\n  end\n\n  # 分析 SDGs 關鍵字\n  def analyze_sdgs_keywords(content)\n    text = remove_markdown(content)\n    \n    matched_sdgs = []\n    sdg_details = {}\n\n    SDGS_KEYWORDS.each do |sdg, keywords|\n      matches = keywords.select { |keyword| text.include?(keyword) }\n      \n      if matches.any?\n        matched_sdgs << sdg\n        sdg_details[sdg] = {\n          matched_keywords: matches,\n          count: matches.length\n        }\n      end\n    end\n\n    {\n      matched_sdgs: matched_sdgs,\n      details: sdg_details,\n      alignment_score: [100, matched_sdgs.length * 20].min\n    }\n  end\n\n  # 偵測常見錯誤\n  def detect_common_errors(content)\n    errors = []\n\n    # 檢查重複標點符號\n    errors << \"發現重複標點符號\" if content.match?(/[。，！？]{2,}/)\n    \n    # 檢查全形/半形混用\n    errors << \"全形半形數字混用\" if content.match?(/\\\\d/) && content.match?(/[０-９]/)\n    \n    # 檢查多餘空格\n    errors << \"發現多餘空格\" if content.match?(/\\\\s{3,}/)\n    \n    # 檢查錯誤的引號使用\n    errors << \"引號使用不一致\" if content.include?(\"「\") && content.include?('\"')\n\n    {\n      count: errors.length,\n      errors: errors,\n      has_errors: errors.any?\n    }\n  end\n\n  # 計算統計資訊\n  def calculate_statistics(content)\n    text = remove_markdown(content)\n    \n    {\n      total_characters: text.length,\n      chinese_characters: text.scan(/[\\\\u4e00-\\\\u9fff]/).length,\n      english_words: text.scan(/[a-zA-Z]+/).length,\n      numbers: text.scan(/\\\\d+/).length,\n      punctuation: text.scan(/[，。！？、；：]/).length,\n      lines: content.lines.count,\n      paragraphs: content.split(/\\n\\n+/).length\n    }\n  end\n\n  # 移除 Markdown 語法\n  def remove_markdown(content)\n    text = content.dup\n    text.gsub!(%r{^#\\{1,6}\\s+}, '')\n    text.gsub!(/[*_]{1,2}([^*_]+)[*_]{1,2}/, '\\1')\n    text.gsub!(/\\[([^\\]]+)\\]\\([^)]+\\)/, '\\1')\n    text.gsub!(/!\\[([^\\]]*)\\]\\([^)]+\\)/, '')\n    text.gsub!(/```[\\s\\S]*?```/, '')\n    text.gsub!(/`([^`]+)`/, '\\1')\n    text.gsub!(/^[-*_]{3,}$/, '')\n    text.gsub!(/^[\\\\s]*[-*+]\\\\s+/, '')\n    text.gsub!(/^[\\\\s]*\\\\d+\\\\.\\\\s+/, '')\n    text.gsub!(/^>\\\\s+/, '')\n    text.gsub!(/<[^>]+>/, '')\n    text.strip\n  end\n\n  # 生成可讀性建議\n  def generate_readability_recommendation(score)\n    case score\n    when 80..100\n      \"可讀性良好\"\n    when 60..79\n      \"可讀性中等，建議簡化部分長句\"\n    else\n      \"可讀性偏低，建議增加段落分隔並縮短句子\"\n    end\n  end\n\n  # 生成結構建議\n  def generate_structure_recommendation(checks)\n    recommendations = []\n    recommendations << \"建議加入標題\" unless checks[:has_title]\n    recommendations << \"建議加入章節標題\" unless checks[:has_sections]\n    recommendations << \"建議使用清單來組織內容\" unless checks[:has_lists]\n    \n    recommendations.empty? ? \"結構良好\" : recommendations.join(\"；\")\n  end\nend\nRUBY