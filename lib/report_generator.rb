# frozen_string_literal: true

require 'json'
require 'fileutils'
require_relative 'document_validator'
require_relative 'content_analyzer'
require_relative 'checklist_validator'

# 報告生成模組
# 整合所有驗證與分析結果，生成多種格式的報告
class ReportGenerator
  attr_reader :validator, :analyzer, :checklist_validator

  def initialize
    @validator = DocumentValidator.new
    @analyzer = ContentAnalyzer.new
    @checklist_validator = ChecklistValidator.new
    @report_data = {}
  end

  # 生成完整報告
  def generate_full_report(base_path = '.')
    puts "正在執行完整驗證與分析..."
    
    # 執行所有驗證與分析
    @validator.validate_project(base_path)
    @analyzer.analyze_project(base_path)
    @checklist_validator.validate

    # 彙整報告數據
    @report_data = {
      timestamp: Time.now,
      validation: {
        summary: @validator.summary,
        results: @validator.results
      },
      analysis: {
        summary: @analyzer.summary,
        results: @analyzer.analysis_results
      },
      checklist: {
        summary: @checklist_validator.generate_report,
        completion: @checklist_validator.completion_percentage,
        pending: @checklist_validator.pending_items,
        completed: @checklist_validator.completed_items
      },
      recommendations: generate_recommendations
    }

    @report_data
  end

  # 生成 Markdown 格式報告
  def generate_markdown_report(output_path = 'validation_report.md')
    generate_full_report if @report_data.empty?

    markdown = build_markdown_content
    
    FileUtils.mkdir_p(File.dirname(output_path))
    File.write(output_path, markdown, encoding: 'utf-8')
    
    {
      success: true,
      format: :markdown,
      output_path: output_path,
      file_size: File.size(output_path)
    }
  end

  # 生成 JSON 格式報告
  def generate_json_report(output_path = 'validation_report.json')
    generate_full_report if @report_data.empty?

    FileUtils.mkdir_p(File.dirname(output_path))
    File.write(output_path, JSON.pretty_generate(@report_data), encoding: 'utf-8')
    
    {
      success: true,
      format: :json,
      output_path: output_path,
      file_size: File.size(output_path)
    }
  end

  # 生成 HTML 格式報告
  def generate_html_report(output_path = 'validation_report.html')
    generate_full_report if @report_data.empty?

    html = build_html_content
    
    FileUtils.mkdir_p(File.dirname(output_path))
    File.write(output_path, html, encoding: 'utf-8')
    
    {
      success: true,
      format: :html,
      output_path: output_path,
      file_size: File.size(output_path)
    }
  end

  # 生成所有格式的報告
  def generate_all_reports(output_dir = 'reports')
    FileUtils.mkdir_p(output_dir)

    results = {
      markdown: generate_markdown_report(File.join(output_dir, 'report.md')),
      json: generate_json_report(File.join(output_dir, 'report.json')),
      html: generate_html_report(File.join(output_dir, 'report.html'))
    }

    puts "\n報告已生成:"
    results.each do |format, result|
      puts "  #{format.to_s.upcase}: #{result[:output_path]}"
    end

    results
  end

  # 取得驗證摘要
  def validation_summary
    generate_full_report if @report_data.empty?
    
    {
      total_files: @validator.results.length,
      passed: @validator.results.count { |r| r[:valid] },
      checklist_completion: @checklist_validator.completion_percentage,
      has_errors: @validator.results.any? { |r| !r[:valid] }
    }
  end

  private

  # 生成建議
  def generate_recommendations
    recommendations = []

    # 基於驗證結果的建議
    @validator.results.each do |result|
      unless result[:valid]
        recommendations << {
          type: :validation,
          file: File.basename(result[:file]),
          message: result[:message],
          priority: :high
        }
      end
    end

    # 基於分析結果的建議
    @analyzer.analysis_results.each do |file, analysis|
      if analysis[:readability][:score] < 70
        recommendations << {
          type: :readability,
          file: File.basename(file),
          message: analysis[:readability][:recommendation],
          priority: :medium
        }
      end

      if analysis[:common_errors][:count] > 0
        recommendations << {
          type: :errors,
          file: File.basename(file),
          message: "發現 #{analysis[:common_errors][:count]} 個常見錯誤",
          priority: :high
        }
      end
    end

    # 基於檢查清單的建議
    @checklist_validator.pending_items.each do |item|
      recommendations << {
        type: :checklist,
        message: "待完成: #{item[:description]}",
        priority: :medium
      }
    end

    recommendations
  end

  # 建立 Markdown 內容
  def build_markdown_content
    md = "# 明緯獎學金申請文件驗證報告\n\n"
    md += "生成時間: #{@report_data[:timestamp].strftime('%Y-%m-%d %H:%M:%S')}\n\n"
    md += "---\n\n"

    # 文件驗證部分
    md += "## 一、文件驗證\n\n"
    md += @report_data[:validation][:summary]
    md += "\n\n"

    # 內容分析部分
    md += "## 二、內容分析\n\n"
    md += @report_data[:analysis][:summary]
    md += "\n\n"

    # 檢查清單部分
    md += "## 三、檢查清單\n\n"
    md += @report_data[:checklist][:summary]
    md += "\n\n"

    # 建議事項
    md += "## 四、改進建議\n\n"
    if @report_data[:recommendations].empty?
      md += "✓ 所有檢查項目均已通過，沒有改進建議。\n"
    else
      @report_data[:recommendations].group_by { |r| r[:priority] }.each do |priority, recs|
        md += "### #{priority_label(priority)}\n\n"
        recs.each_with_index do |rec, idx|
          md += "#{idx + 1}. **#{rec[:file] || '一般'}**: #{rec[:message]}\n"
        end
        md += "\n"
      end
    end

    md
  end

  # 建立 HTML 內容
  def build_html_content
    html = <<~HTML
      <!DOCTYPE html>
      <html lang="zh-TW">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>明緯獎學金申請文件驗證報告</title>
        <style>
          body {
            font-family: "Microsoft JhengHei", "Noto Sans TC", Arial, sans-serif;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            line-height: 1.6;
          }
          h1 { color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 10px; }
          h2 { color: #34495e; margin-top: 30px; }
          .summary { background: #ecf0f1; padding: 15px; border-radius: 5px; margin: 20px 0; }
          .success { color: #27ae60; }
          .warning { color: #f39c12; }
          .error { color: #e74c3c; }
          table { width: 100%; border-collapse: collapse; margin: 20px 0; }
          th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
          th { background-color: #3498db; color: white; }
          .recommendation { background: #fff3cd; border-left: 4px solid #ffc107; padding: 10px; margin: 10px 0; }
        </style>
      </head>
      <body>
        <h1>明緯獎學金申請文件驗證報告</h1>
        <p>生成時間: #{@report_data[:timestamp].strftime('%Y-%m-%d %H:%M:%S')}</p>

        <div class="summary">
          <h2>執行摘要</h2>
          <p>檢查清單完成率: <strong>#{@report_data[:checklist][:completion]}%</strong></p>
          <p>文件驗證: #{@validator.results.count { |r| r[:valid] }}/#{@validator.results.length} 通過</p>
        </div>

        <h2>文件驗證結果</h2>
        #{build_validation_table_html}

        <h2>改進建議</h2>
        #{build_recommendations_html}
      </body>
      </html>
    HTML

    html
  end

  # 建立驗證結果表格
  def build_validation_table_html
    html = "<table><tr><th>檔案</th><th>狀態</th><th>訊息</th></tr>"
    @validator.results.each do |result|
      status_class = result[:valid] ? 'success' : 'error'
      status_text = result[:valid] ? '✓ 通過' : '✗ 失敗'
      html += "<tr>"
      html += "<td>#{File.basename(result[:file])}</td>"
      html += "<td class='#{status_class}'>#{status_text}</td>"
      html += "<td>#{result[:message]}</td>"
      html += "</tr>"
    end
    html += "</table>"
    html
  end

  # 建立建議列表
  def build_recommendations_html
    return "<p class='success'>✓ 所有檢查項目均已通過</p>" if @report_data[:recommendations].empty?

    html = ""
    @report_data[:recommendations].each do |rec|
      html += "<div class='recommendation'>"
      html += "<strong>#{rec[:file] || '一般'}</strong>: #{rec[:message]}"
      html += "</div>"
    end
    html
  end

  # 優先級標籤
  def priority_label(priority)
    case priority
    when :high
      "🔴 高優先級"
    when :medium
      "🟡 中優先級"
    when :low
      "🟢 低優先級"
    else
      "一般"
    end
  end
end
