# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/pdf_merger'

RSpec.describe PDFMerger do
  let(:merger) { described_class.new }

  describe '#merge' do
    it '驗證輸入檔案為空時拋出錯誤' do
      expect {
        merger.merge([])
      }.to raise_error(ArgumentError, /PDF 檔案列表不能為空/)
    end

    it '驗證不存在的檔案時拋出錯誤' do
      expect {
        merger.merge(['nonexistent.pdf'])
      }.to raise_error(/檔案不存在/)
    end
  end

  describe '#validate_merged_pdf' do
    it '尚未合併時返回無效狀態' do
      result = merger.validate_merged_pdf
      expect(result[:valid]).to be false
    end
  end
end
