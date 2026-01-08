# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/document_validator'
require 'fileutils'

RSpec.describe DocumentValidator do
  let(:validator) { described_class.new }

  after(:each) do
    # 清理臨時測試檔案
    FileUtils.rm_f('spec/temp_test.md')
  end

  describe '#validate_file' do
    it '驗證不存在的檔案' do
      result = validator.validate_file('nonexistent.md')
      expect(result[:valid]).to be false
      expect(result[:message]).to include('檔案不存在')
    end

    it '驗證字數限制' do
      # 建立臨時測試檔案
      test_file = 'spec/temp_test.md'
      File.write(test_file, '# 測試\n' + '測試' * 100)
      
      result = validator.validate_file(test_file, 50)
      expect(result).to have_key(:valid)
      expect(result).to have_key(:word_count)
      
      File.delete(test_file) if File.exist?(test_file)
    end
  end

  describe '#validate_project' do
    it '驗證專案所有文件' do
      results = validator.validate_project
      expect(results).to be_an(Array)
    end
  end

  describe '#summary' do
    it '生成驗證摘要' do
      validator.validate_project
      summary = validator.summary
      expect(summary).to include('驗證摘要')
    end
  end
end
