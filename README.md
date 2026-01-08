# 明緯獎學金申請文件處理工具

完整的 Ruby 工具包，用於驗證、轉換、合併和分析明緯獎學金申請文件，並提供 CLI 和 GUI 介面，可打包成跨平台可執行軟體。

## ⚠️ 送件前必讀

**在送出申請前，請務必完成 [CHECKLIST.md](CHECKLIST.md) 中的所有檢查項目。**

此檢查清單包含：
- 申請資格確認（中華民國國籍、當年度出國留學、申請期間）
- 5 項必備文件完整性檢查
- PDF 合併與檔名格式檢查
- 內容品質與 SDGs 對齊檢查
- 送件準備與最終驗收

任何不合規的項目都可能導致申請被直接退回或不受理，請務必仔細檢查。

## 功能特色

### 核心功能

1. **文件驗證**：自動檢查字數限制、格式、完整性
2. **PDF 轉換**：將 Markdown 轉換為 PDF（支援繁體中文）
3. **PDF 合併**：合併多個 PDF 為單一文件
4. **內容分析**：分析可讀性、關鍵字密度、SDGs 對齊
5. **檢查清單驗證**：自動驗證 README 中的檢查清單
6. **報告生成**：生成 Markdown、JSON、HTML 格式的驗證報告
7. **自動化 CI/CD**：GitHub Actions 整合

### 使用介面

- **CLI 命令列工具**：快速執行各項功能
- **GUI 圖形介面**：使用者友善的視窗應用程式
- **可執行軟體**：打包為 Windows .exe 和 macOS .pkg

## 安裝

### 系統需求

- Ruby 3.2 或更高版本
- Bundler

### 安裝步驟

```bash
# 1. 複製專案
git clone <repository_url>
cd uk_scholarship

# 2. 安裝依賴
bundle install

# 3. (可選) 執行測試
bundle exec rspec

# 4. (可選) 執行 Rake 任務
bundle exec rake setup    # 建立目錄結構
```

## 使用流程

### 送件前完整流程

1. **準備申請文件**：根據 `2025_明緯獎學金_李沛宸/` 目錄中的模板填寫所有文件
2. **驗證文件內容**：使用 CLI 或 GUI 工具驗證文件格式與字數
3. **轉換為 PDF**：將 Markdown 文件轉換為 PDF
4. **合併 PDF**：將所有文件合併為單一 PDF，檔名為 `2025明緯獎學金-李沛宸.pdf`
5. **完成檢查清單**：**必須完成 [CHECKLIST.md](CHECKLIST.md) 中的所有檢查項目**
6. **準備送件**：參考 `2025_明緯獎學金_李沛宸/送件指南.md` 準備 Email 與附件
7. **送出申請**：在申請期間內（5/1-7/31）寄送到 info@meanwellfoundation.org

### 詳細文件說明

- **送件前檢查清單**：[CHECKLIST.md](CHECKLIST.md) - 送件前必讀
- **官方規格要求**：`2025_明緯獎學金_李沛宸/requirements.md`
- **送件流程指南**：`2025_明緯獎學金_李沛宸/送件指南.md`
- **申請包說明**：`2025_明緯獎學金_李沛宸/README.md`

## 使用方式

### 方式一：使用 CLI 命令列工具

```bash
# 驗證所有文件
ruby scripts/cli.rb validate

# 轉換 Markdown 為 PDF
ruby scripts/cli.rb convert

# 合併 PDF 檔案
ruby scripts/cli.rb merge

# 分析內容品質
ruby scripts/cli.rb analyze

# 生成完整報告
ruby scripts/cli.rb report

# 執行完整流程
ruby scripts/cli.rb all
```

### 方式二：使用 GUI 圖形介面

```bash
# 啟動 GUI 應用程式
ruby gui/main_window.rb
```

GUI 提供以下功能：

- 點擊按鈕執行各項功能
- 即時顯示執行進度
- 日誌輸出面板
- 開啟輸出資料夾

### 方式三：使用 Rake 任務

```bash
# 驗證文件
bundle exec rake validate

# 轉換為 PDF
bundle exec rake convert

# 合併 PDF
bundle exec rake merge

# 分析內容
bundle exec rake analyze

# 生成報告
bundle exec rake report

# 執行全部流程
bundle exec rake all
```

## 專案結構

```
uk_scholarship/
├── Gemfile                          # Ruby 依賴設定
├── Rakefile                         # Rake 任務定義
├── lib/                             # 核心模組
│   ├── document_validator.rb       # 文件驗證
│   ├── pdf_converter.rb            # PDF 轉換
│   ├── pdf_merger.rb               # PDF 合併
│   ├── content_analyzer.rb         # 內容分析
│   ├── checklist_validator.rb      # 檢查清單驗證
│   └── report_generator.rb         # 報告生成
├── gui/                             # GUI 介面
│   └── main_window.rb              # 主視窗
├── scripts/                         # CLI 腳本
│   └── cli.rb                      # CLI 入口
├── spec/                            # 測試檔案
│   ├── spec_helper.rb
│   ├── document_validator_spec.rb
│   └── pdf_merger_spec.rb
├── build/                           # 打包腳本
│   ├── build_windows.rb            # Windows 打包
│   └── build_macos.rb              # macOS 打包
├── .github/workflows/               # GitHub Actions
│   ├── ruby-validation.yml         # 驗證與建構
│   └── release.yml                 # 發布流程
├── product/                         # 輸出目錄
└── reports/                         # 報告目錄
```

## 打包成可執行軟體

### Windows .exe

```bash
# 安裝 OCRA
gem install ocra

# 執行打包腳本
ruby build/build_windows.rb

# 輸出檔案
# - build/scholarship-cli.exe
# - build/scholarship-gui.exe
```

### macOS .pkg

```bash
# 執行打包腳本
ruby build/build_macos.rb

# 輸出檔案
# - build/ScholarshipTools.app
# - build/ScholarshipTools.pkg
```

## CI/CD 整合

本專案已整合 GitHub Actions，提供自動化工作流程：

### 持續整合 (ruby-validation.yml)

- 自動執行測試
- 驗證文件
- 生成 PDF
- 上傳 artifacts

### 自動發布 (release.yml)

- 建立 Windows .exe
- 建立 macOS .pkg
- 上傳到 GitHub Releases

觸發方式：

```bash
# 建立 release tag
git tag v1.0.0
git push origin v1.0.0
```

## 開發指南

### 新增模組

1. 在 `lib/` 目錄建立新模組
2. 在 `spec/` 目錄建立對應測試
3. 在 `scripts/cli.rb` 加入命令
4. 在 `gui/main_window.rb` 加入按鈕

### 執行測試

```bash
# 執行所有測試
bundle exec rspec

# 執行特定測試
bundle exec rspec spec/document_validator_spec.rb

# 查看測試覆蓋率
bundle exec rspec --format documentation
```

### 程式碼風格

```bash
# 檢查程式碼風格
bundle exec rubocop

# 自動修正問題
bundle exec rubocop -a
```

## 技術棧

- **Ruby**: 3.2+
- **PDF 處理**: Prawn, CombinePDF
- **Markdown 解析**: Kramdown
- **GUI 框架**: Glimmer DSL for LibUI
- **CLI 工具**: Colorize
- **測試框架**: RSpec
- **打包工具**: OCRA (Windows), Platypus (macOS)

## 常見問題

### Q: 中文顯示不正常？

A: 確保已安裝中文字體。Linux 系統需要安裝 `fonts-noto-cjk`。

### Q: GUI 無法啟動？

A: 確保已安裝 `glimmer-dsl-libui` gem，並檢查系統是否支援 LibUI。

### Q: PDF 合併失敗？

A: 確保 `product/` 目錄中有需要合併的 PDF 檔案。

### Q: 如何自訂 PDF 樣式？

A: 編輯 `lib/pdf_converter.rb` 中的 `DEFAULT_` 常數。

## 貢獻

歡迎提交 Issue 和 Pull Request！

## 授權

本專案僅供個人使用。

## 聯絡方式

如有問題請建立 Issue 或聯絡專案維護者。

---

建立日期: 2025
版本: 1.0.0
