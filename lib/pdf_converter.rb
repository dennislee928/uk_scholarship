# frozen_string_literal: true

require 'kramdown'
require 'prawn'
require 'prawn/table'
require 'fileutils'

# PDF 轉換模組
# 負責將 Markdown 轉換為 PDF（支援繁體中文）
class PDFConverter
  DEFAULT_FONT_SIZE = 12
  DEFAULT_LINE_HEIGHT = 1.5
  DEFAULT_MARGIN = 50

  attr_reader :options

  def initialize(options = {})
    @options = {
      font_size: options[:font_size] || DEFAULT_FONT_SIZE,
      line_height: options[:line_height] || DEFAULT_LINE_HEIGHT,
      margin: options[:margin] || DEFAULT_MARGIN,
      page_size: options[:page_size] || 'A4',
      font_family: options[:font_family] || '儷宋'
    }
  end

  # 轉換單一 Markdown 檔案為 PDF
  def convert(markdown_file, output_pdf = nil)
    raise "檔案不存在: #{markdown_file}" unless File.exist?(markdown_file)

    # 確定輸出路徑
    output_pdf ||= generate_output_path(markdown_file)
    
    # 讀取 Markdown 內容
    markdown_content = File.read(markdown_file, encoding: 'utf-8')
    
    # 解析 Markdown
    doc = Kramdown::Document.new(markdown_content, input: 'GFM')
    
    # 建立 PDF
    create_pdf(doc, output_pdf, File.basename(markdown_file, '.md'))

    {
      success: true,
      input_file: markdown_file,
      output_file: output_pdf,
      file_size: File.size(output_pdf)
    }
  rescue StandardError => e
    {
      success: false,
      input_file: markdown_file,
      error: e.message
    }
  end

  # 批次轉換多個 Markdown 檔案
  def convert_batch(markdown_files, output_dir = 'product')
    FileUtils.mkdir_p(output_dir)

    results = markdown_files.map do |md_file|
      output_file = File.join(output_dir, File.basename(md_file, '.md') + '.pdf')
      result = convert(md_file, output_file)
      
      yield(result) if block_given?
      
      result
    end

    {
      total: results.length,
      success: results.count { |r| r[:success] },
      failed: results.count { |r| !r[:success] },
      results: results
    }
  end

  # 轉換專案中的所有 Markdown 檔案
  def convert_project(base_path = '.', output_dir = 'product')
    markdown_files = [
      File.join(base_path, '2025_明緯獎學金_李沛宸/01_申請書/300字短答_為何申請.md'),
      File.join(base_path, '2025_明緯獎學金_李沛宸/02_自傳與學習計畫/自傳.md'),
      File.join(base_path, '2025_明緯獎學金_李沛宸/02_自傳與學習計畫/短期學習計畫.md'),
      File.join(base_path, '2025_明緯獎學金_李沛宸/02_自傳與學習計畫/未來工作應用.md')
    ]

    existing_files = markdown_files.select { |f| File.exist?(f) }
    
    if existing_files.empty?
      raise "找不到任何 Markdown 檔案"
    end

    convert_batch(existing_files, output_dir) do |result|
      if result[:success]
        puts "✓ 已轉換: #{File.basename(result[:input_file])}"
      else
        puts "✗ 轉換失敗: #{File.basename(result[:input_file])} - #{result[:error]}"
      end
    end
  end

  private

  # 建立 PDF 文件
  def create_pdf(kramdown_doc, output_path, title)
    Prawn::Document.generate(output_path, 
                            page_size: @options[:page_size],
                            margin: @options[:margin]) do |pdf|
      
      # 設定字體（使用系統中文字體）
      setup_fonts(pdf)
      
      # 設定基本樣式
      pdf.font_size @options[:font_size]
      
      # 渲染 Markdown 內容
      render_kramdown_elements(pdf, kramdown_doc.root.children)
      
      # 加入頁碼
      add_page_numbers(pdf)
    end
  end

  # 設定字體
  def setup_fonts(pdf)
    # 注意：這裡使用 Prawn 內建字體
    # 實際部署時可能需要自行提供中文字體檔案
    # pdf.font_families.update(
    #   "NotoSans" => {
    #     normal: "path/to/NotoSansCJKtc-Regular.ttf",
    #     bold: "path/to/NotoSansCJKtc-Bold.ttf"
    #   }
    # )
    # pdf.font "NotoSans"
  end

  # 渲染 Kramdown 元素
  def render_kramdown_elements(pdf, elements)
    elements.each do |element|
      case element.type
      when :header
        render_header(pdf, element)
      when :p
        render_paragraph(pdf, element)
      when :ul, :ol
        render_list(pdf, element)
      when :codeblock
        render_codeblock(pdf, element)
      when :blockquote
        render_blockquote(pdf, element)
      when :hr
        pdf.stroke_horizontal_rule
        pdf.move_down 10
      end
    end
  end

  # 渲染標題
  def render_header(pdf, element)
    level = element.options[:level]
    text = extract_text(element)
    
    pdf.move_down 10 if pdf.cursor < pdf.bounds.height - 20
    
    size_map = { 1 => 24, 2 => 20, 3 => 18, 4 => 16, 5 => 14, 6 => 12 }
    pdf.font_size(size_map[level] || 12) do
      pdf.text text, style: :bold
    end
    
    pdf.move_down 8
  end

  # 渲染段落
  def render_paragraph(pdf, element)
    text = extract_text(element)
    pdf.text text, inline_format: true, leading: (@options[:font_size] * (@options[:line_height] - 1))
    pdf.move_down 10
  end

  # 渲染清單
  def render_list(pdf, element)
    element.children.each_with_index do |item, index|
      marker = element.type == :ul ? '•' : "#{index + 1}."
      text = extract_text(item)
      
      pdf.indent(20) do
        pdf.text "#{marker} #{text}", inline_format: true
      end
    end
    pdf.move_down 10
  end

  # 渲染程式碼區塊
  def render_codeblock(pdf, element)
    pdf.fill_color 'F5F5F5'
    pdf.fill_rectangle [0, pdf.cursor], pdf.bounds.width, pdf.height_of(element.value) + 20
    pdf.fill_color '000000'
    
    pdf.move_down 10
    pdf.indent(10) do
      pdf.text element.value, size: 10, font: 'Courier'
    end
    pdf.move_down 10
  end

  # 渲染引用
  def render_blockquote(pdf, element)
    pdf.stroke_color 'CCCCCC'
    pdf.stroke_vertical_line pdf.cursor, pdf.cursor - 50, at: 0
    pdf.stroke_color '000000'
    
    pdf.indent(15) do
      pdf.fill_color '666666'
      pdf.text extract_text(element), inline_format: true
      pdf.fill_color '000000'
    end
    pdf.move_down 10
  end

  # 提取元素文字
  def extract_text(element)
    case element.type
    when :text
      element.value
    when :strong
      "<b>#{extract_text(element.children.first)}</b>"
    when :em
      "<i>#{extract_text(element.children.first)}</i>"
    else
      element.children.map { |child| extract_text(child) }.join
    end
  end

  # 加入頁碼
  def add_page_numbers(pdf)
    pdf.number_pages "<page> / <total>", 
                     at: [pdf.bounds.right - 50, 0],
                     width: 50,
                     align: :right,
                     size: 10
  end

  # 產生輸出路徑
  def generate_output_path(markdown_file)
    basename = File.basename(markdown_file, '.md')
    File.join(File.dirname(markdown_file), "#{basename}.pdf")
  end
end
