#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'colorize'
require_relative '../lib/document_validator'
require_relative '../lib/pdf_converter'
require_relative '../lib/pdf_merger'
require_relative '../lib/content_analyzer'
require_relative '../lib/checklist_validator'
require_relative '../lib/report_generator'

# CLI 主程式
class ScholarshipCLI
  def initialize
    @options = {}
  end

  def run(args = ARGV)
    command = args.shift
    
    case command
    when 'validate'
      run_validation
    when 'convert'
      run_conversion
    when 'merge'
      run_merge
    when 'analyze'
      run_analysis
    when 'report'
      run_report
    when 'all'
      run_all
    when 'help', '-h', '--help', nil
      show_help
    else
      puts "未知的命令: #{command}".colorize(:red)
      show_help
      exit 1
    end
  end

  private

  def run_validation
    puts "\n開始驗證文件...".colorize(:yellow)
    
    validator = DocumentValidator.new
    validator.validate_project
    
    puts "\n" + validator.summary
    
    all_valid = validator.results.all? { |r| r[:valid] }
    if all_valid
      puts "\n✓ 所有文件驗證通過！".colorize(:green)
    else
      puts "\n✗ 部分文件驗證失敗，請檢查上述訊息。".colorize(:red)
      exit 1
    end
  end

  def run_conversion
    puts "\n開始轉換 Markdown 為 PDF...".colorize(:yellow)
    
    converter = PDFConverter.new
    result = converter.convert_project

    puts "\n轉換結果:"
    puts "  總計: #{result[:total]} 個檔案"
    puts "  成功: #{result[:success]} 個".colorize(:green)
    puts "  失敗: #{result[:failed]} 個".colorize(result[:failed] > 0 ? :red : :white)

    if result[:failed] > 0
      puts "\n失敗的檔案:"
      result[:results].select { |r| !r[:success] }.each do |r|
        puts "  ✗ #{File.basename(r[:input_file])}: #{r[:error]}".colorize(:red)
      end
      exit 1
    else
      puts "\n✓ 所有檔案已成功轉換為 PDF！".colorize(:green)
    end
  end

  def run_merge
    puts "\n開始合併 PDF 檔案...".colorize(:yellow)
    
    merger = PDFMerger.new
    result = merger.merge_project_pdfs

    puts "\n合併結果:"
    puts "  輸出檔案: #{result[:output_path]}"
    puts "  總頁數: #{result[:page_count]}"
    puts "  檔案數量: #{result[:file_count]}"
    puts "\n✓ PDF 已成功合併！".colorize(:green)
  rescue StandardError => e
    puts "\n✗ 合併失敗: #{e.message}".colorize(:red)
    exit 1
  end

  def run_analysis
    puts "\n開始分析內容...".colorize(:yellow)
    
    analyzer = ContentAnalyzer.new
    analyzer.analyze_project

    puts "\n" + analyzer.summary
    puts "\n✓ 內容分析完成！".colorize(:green)
  end

  def run_report
    puts "\n開始生成報告...".colorize(:yellow)
    
    reporter = ReportGenerator.new
    results = reporter.generate_all_reports

    puts "\n✓ 報告已生成！".colorize(:green)
    results.each do |format, result|
      puts "  #{format.to_s.upcase}: #{result[:output_path]}".colorize(:cyan)
    end
  end

  def run_all
    puts "\n" + "=" * 60
    puts "執行完整流程".center(60).colorize(:cyan).bold
    puts "=" * 60 + "\n"

    begin
      puts "\n[1/5] 驗證文件".colorize(:yellow).bold
      run_validation

      puts "\n[2/5] 轉換為 PDF".colorize(:yellow).bold
      run_conversion

      puts "\n[3/5] 合併 PDF".colorize(:yellow).bold
      run_merge

      puts "\n[4/5] 分析內容".colorize(:yellow).bold
      run_analysis

      puts "\n[5/5] 生成報告".colorize(:yellow).bold
      run_report

      puts "\n" + "=" * 60
      puts "✓ 所有流程執行完畢！".center(60).colorize(:green).bold
      puts "=" * 60 + "\n"
    rescue StandardError => e
      puts "\n✗ 執行過程中發生錯誤: #{e.message}".colorize(:red)
      puts e.backtrace.first(5).join("\n").colorize(:yellow)
      exit 1
    end
  end

  def show_help
    help_text = <<~HELP

      #{'明緯獎學金申請文件處理工具'.colorize(:cyan).bold}

      #{' 用法:'.colorize(:yellow)} ruby scripts/cli.rb [命令]

      #{' 可用命令:'.colorize(:yellow)}
        validate   驗證所有文件（字數、格式、完整性）
        convert    轉換 Markdown 檔案為 PDF
        merge      合併所有 PDF 為單一檔案
        analyze    分析內容品質與可讀性
        report     生成完整驗證報告（Markdown、JSON、HTML）
        all        執行所有流程（驗證 → 轉換 → 合併 → 分析 → 報告）
        help       顯示此幫助訊息

      #{'  範例:'.colorize(:yellow)}
        ruby scripts/cli.rb validate     # 驗證所有文件
        ruby scripts/cli.rb convert      # 轉換為 PDF
        ruby scripts/cli.rb all          # 執行完整流程

      #{'  更多資訊:'.colorize(:yellow)}
        請參閱 README.md 以獲取詳細文件
    HELP

    puts help_text
  end
end

# 執行 CLI
if __FILE__ == $PROGRAM_NAME
  cli = ScholarshipCLI.new
  cli.run(ARGV)
end
