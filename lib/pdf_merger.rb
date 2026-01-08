# frozen_string_literal: true

require 'combine_pdf'
require 'fileutils'

# PDF 合併模組
# 負責將多個 PDF 合併成單一檔案
class PDFMerger
  attr_reader :output_path, :merged_pdf

  DEFAULT_OUTPUT_NAME = '2025 明緯獎學金-李沛宸.pdf'

  def initialize(output_path = nil)
    @output_path = output_path || File.join('product', DEFAULT_OUTPUT_NAME)
    @merged_pdf = nil
    @page_count = 0
  end

  # 合併多個 PDF 檔案
  def merge(pdf_files, options = {})
    validate_input_files!(pdf_files)

    @merged_pdf = CombinePDF.new
    
    pdf_files.each_with_index do |pdf_file, index|
      begin
        pdf = CombinePDF.load(pdf_file)
        @merged_pdf << pdf
        @page_count += pdf.pages.length
        
        yield(index + 1, pdf_files.length, pdf_file) if block_given?
      rescue StandardError => e
        raise "合併 #{pdf_file} 時發生錯誤: #{e.message}"
      end
    end

    # 加入元資料
    add_metadata(options[:metadata]) if options[:metadata]

    # 儲存合併後的 PDF
    save_merged_pdf

    {
      success: true,
      output_path: @output_path,
      page_count: @page_count,
      file_count: pdf_files.length
    }
  end

  # 合併專案中的所有 PDF
  def merge_project_pdfs(base_path = 'product')
    pdf_files = [
      File.join(base_path, '300字短答_為何申請.pdf'),
      File.join(base_path, '自傳.pdf'),
      File.join(base_path, '短期學習計畫.pdf'),
      File.join(base_path, '未來工作應用.pdf')
    ]

    # 檢查檔案是否存在
    existing_files = pdf_files.select { |f| File.exist?(f) }
    
    if existing_files.empty?
      raise "找不到任何 PDF 檔案在 #{base_path} 目錄中"
    end

    merge(existing_files) do |current, total, file|
      puts "正在合併 (#{current}/#{total}): #{File.basename(file)}"
    end
  end

  # 驗證合併結果
  def validate_merged_pdf
    return { valid: false, message: "尚未合併 PDF" } unless @merged_pdf

    {
      valid: true,
      page_count: @page_count,
      file_size: File.size(@output_path),
      output_path: @output_path
    }
  end

  # 加入頁碼
  def add_page_numbers(options = {})
    return unless @merged_pdf

    font_size = options[:font_size] || 10
    position = options[:position] || :bottom_center

    @merged_pdf.pages.each_with_index do |page, index|
      page_num = index + 1
      # 使用 CombinePDF 的方法加入頁碼
      # 注意：這需要進階的 PDF 操作，可能需要額外的 gem
      # 暫時保留此功能規劃
    end
  end

  # 加入目錄/書籤
  def add_table_of_contents(toc_entries)
    return unless @merged_pdf
    
    # 加入書籤功能
    # 需要更進階的 PDF 操作
    # 暫時保留此功能規劃
  end

  # 取得合併後的資訊
  def info
    return {} unless @merged_pdf

    {
      output_path: @output_path,
      page_count: @page_count,
      file_size: format_file_size(File.size(@output_path)),
      created_at: File.mtime(@output_path)
    }
  end

  private

  # 驗證輸入檔案
  def validate_input_files!(pdf_files)
    raise ArgumentError, "PDF 檔案列表不能為空" if pdf_files.empty?

    pdf_files.each do |file|
      raise "檔案不存在: #{file}" unless File.exist?(file)
      raise "不是 PDF 檔案: #{file}" unless File.extname(file).downcase == '.pdf'
    end
  end

  # 儲存合併後的 PDF
  def save_merged_pdf
    # 確保輸出目錄存在
    FileUtils.mkdir_p(File.dirname(@output_path))

    # 儲存 PDF
    @merged_pdf.save @output_path

    # 驗證檔案已建立
    raise "無法建立輸出檔案: #{@output_path}" unless File.exist?(@output_path)
  end

  # 加入元資料
  def add_metadata(metadata)
    @merged_pdf.info[:Title] = metadata[:title] if metadata[:title]
    @merged_pdf.info[:Author] = metadata[:author] if metadata[:author]
    @merged_pdf.info[:Subject] = metadata[:subject] if metadata[:subject]
    @merged_pdf.info[:Keywords] = metadata[:keywords] if metadata[:keywords]
    @merged_pdf.info[:Creator] = metadata[:creator] || "Ruby PDF Merger"
    @merged_pdf.info[:Producer] = metadata[:producer] || "CombinePDF"
    @merged_pdf.info[:CreationDate] = Time.now
  end

  # 格式化檔案大小
  def format_file_size(size)
    if size < 1024
      "#{size} B"
    elsif size < 1024 * 1024
      "#{(size / 1024.0).round(2)} KB"
    else
      "#{(size / (1024.0 * 1024)).round(2)} MB"
    end
  end
end
