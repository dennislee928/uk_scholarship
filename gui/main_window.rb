#!/usr/bin/env ruby
# frozen_string_literal: true

require 'glimmer-dsl-libui'
require_relative '../lib/document_validator'
require_relative '../lib/pdf_converter'
require_relative '../lib/pdf_merger'
require_relative '../lib/content_analyzer'
require_relative '../lib/report_generator'

# GUI 主視窗
class MainWindow
  include Glimmer

  def initialize
    @status_text = "就緒"
    @progress = 0
    @log_text = "歡迎使用明緯獎學金文件處理工具\n\n"
  end

  def launch
    window('明緯獎學金文件處理工具', 800, 600) {
      margined true

      vertical_box {
        # 標題區域
        label('明緯獎學金申請文件處理系統') {
          stretchy false
        }

        horizontal_separator {
          stretchy false
        }

        # 功能按鈕區域
        horizontal_box {
          stretchy false

          button('驗證文件') {
            on_clicked do
              run_task { validate_documents }
            end
          }

          button('轉換 PDF') {
            on_clicked do
              run_task { convert_to_pdf }
            end
          }

          button('合併 PDF') {
            on_clicked do
              run_task { merge_pdfs }
            end
          }

          button('分析內容') {
            on_clicked do
              run_task { analyze_content }
            end
          }

          button('生成報告') {
            on_clicked do
              run_task { generate_report }
            end
          }
        end

        horizontal_separator {
          stretchy false
        }

        button('執行全部流程') {
          stretchy false

          on_clicked do
            run_task { run_all_tasks }
          end
        }

        horizontal_separator {
          stretchy false
        }

        # 進度條
        progress_bar {
          stretchy false
          value <= [@progress, :after_write]
        }

        # 狀態標籤
        label {
          stretchy false
          text <= [@status_text, :after_write]
        }

        # 日誌區域
        multiline_entry {
          read_only true
          text <=> [@log_text, :after_write]
        }

        # 底部按鈕
        horizontal_box {
          stretchy false

          button('清除日誌') {
            on_clicked do
              @log_text = ""
            end
          }

          button('開啟輸出資料夾') {
            on_clicked do
              open_output_folder
            end
          }

          button('關於') {
            on_clicked do
              show_about
            end
          }

          button('離開') {
            on_clicked do
              ::LibUI.quit
            end
          }
        }
      }
    }.show
  end

  private

  def run_task
    Thread.new do
      begin
        @progress = 0
        yield
        @status_text = "✓ 完成"
        @progress = 100
      rescue StandardError => e
        @status_text = "✗ 錯誤: #{e.message}"
        log_message("錯誤: #{e.message}", :error)
        @progress = 0
      end
    end
  end

  def validate_documents
    @status_text = "正在驗證文件..."
    log_message("開始驗證文件...", :info)

    validator = DocumentValidator.new
    validator.validate_project

    log_message(validator.summary, :result)
    log_message("驗證完成", :success)
  end

  def convert_to_pdf
    @status_text = "正在轉換為 PDF..."
    log_message("開始轉換 Markdown 為 PDF...", :info)

    converter = PDFConverter.new
    result = converter.convert_project

    log_message("轉換結果: 成功 #{result[:success]}/#{result[:total]}", :result)
    
    if result[:failed] > 0
      log_message("部分檔案轉換失敗", :warning)
    else
      log_message("所有檔案已成功轉換", :success)
    end
  end

  def merge_pdfs
    @status_text = "正在合併 PDF..."
    log_message("開始合併 PDF 檔案...", :info)

    merger = PDFMerger.new
    result = merger.merge_project_pdfs

    log_message("合併完成: #{result[:output_path]}", :result)
    log_message("總頁數: #{result[:page_count]}", :result)
    log_message("PDF 已成功合併", :success)
  end

  def analyze_content
    @status_text = "正在分析內容..."
    log_message("開始分析內容品質...", :info)

    analyzer = ContentAnalyzer.new
    analyzer.analyze_project

    log_message(analyzer.summary, :result)
    log_message("內容分析完成", :success)
  end

  def generate_report
    @status_text = "正在生成報告..."
    log_message("開始生成驗證報告...", :info)

    reporter = ReportGenerator.new
    results = reporter.generate_all_reports

    results.each do |format, result|
      log_message("#{format.to_s.upcase} 報告: #{result[:output_path]}", :result)
    end
    
    log_message("報告生成完成", :success)
  end

  def run_all_tasks
    @status_text = "執行完整流程..."
    log_message("=" * 50, :info)
    log_message("開始執行完整流程", :info)
    log_message("=" * 50, :info)

    @progress = 0
    validate_documents
    @progress = 20

    convert_to_pdf
    @progress = 40

    merge_pdfs
    @progress = 60

    analyze_content
    @progress = 80

    generate_report
    @progress = 100

    log_message("=" * 50, :info)
    log_message("✓ 所有流程執行完畢！", :success)
    log_message("=" * 50, :info)
  end

  def log_message(message, type = :info)
    timestamp = Time.now.strftime("%H:%M:%S")
    prefix = case type
             when :info then "[INFO]"
             when :success then "[SUCCESS]"
             when :warning then "[WARNING]"
             when :error then "[ERROR]"
             when :result then "[RESULT]"
             else "[LOG]"
             end

    @log_text += "#{timestamp} #{prefix} #{message}\n"
  end

  def open_output_folder
    output_dir = File.expand_path('../product', __dir__)
    
    case RbConfig::CONFIG['host_os']
    when /darwin/i
      system("open", output_dir)
    when /linux/i
      system("xdg-open", output_dir)
    when /mswin|mingw|cygwin/i
      system("start", output_dir)
    end
  rescue StandardError => e
    log_message("無法開啟資料夾: #{e.message}", :error)
  end

  def show_about
    msg_box('關於',
            "明緯獎學金文件處理工具\n\n" \
            "版本: 1.0.0\n" \
            "功能: 文件驗證、PDF 轉換、內容分析\n\n" \
            "© 2025")
  end
end

# 啟動 GUI
if __FILE__ == $PROGRAM_NAME
  app = MainWindow.new
  app.launch
end
