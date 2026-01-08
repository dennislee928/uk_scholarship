# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/pdf_merger'

RSpec.describe PDFMerger do
  let(:merger) { described_class.new }

  describe '#merge' do
    it '合併 PDF 檔案' do
      # 測試需要實際的 PDF 檔案
      # 這裡僅作為範例
    end

    it '驗證輸入檔案' do
      expect {
        merger.merge([])
      }.to raise_error(ArgumentError)
    end
  end
end
