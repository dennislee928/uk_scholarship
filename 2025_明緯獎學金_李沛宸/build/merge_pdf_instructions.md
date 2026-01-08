# PDF 合併說明

## 最終輸出

固定檔名：`2025明緯獎學金-李沛宸.pdf`

## 合併順序

請按照以下順序將文件合併為單一 PDF：

1. **01*申請書/300 字短答*為何申請.md**
2. **02\_自傳與學習計畫/自傳.md**
3. **02\_自傳與學習計畫/短期學習計畫.md**
4. **02\_自傳與學習計畫/未來工作應用.md**
5. **03\_錄取在學證明/** 中的證明文件
6. **04\_能力證明附錄/** 中的證明文件

## macOS 轉換與合併步驟

### 步驟 1：安裝必要工具

```bash
# 安裝 Homebrew（如果尚未安裝）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安裝 pandoc（Markdown 轉 PDF）
brew install pandoc

# 安裝基本 tex（PDF 引擎）
brew install basictex
```

### 步驟 2：轉換 Markdown 為 PDF

```bash
# 進入申請包目錄
cd "2025_明緯獎學金_李沛宸"

# 轉換各個 Markdown 文件為 PDF
pandoc "01_申請書/300字短答_為何申請.md" -o "01_申請書/300字短答_為何申請.pdf" --pdf-engine=pdflatex
pandoc "02_自傳與學習計畫/自傳.md" -o "02_自傳與學習計畫/自傳.pdf" --pdf-engine=pdflatex
pandoc "02_自傳與學習計畫/短期學習計畫.md" -o "02_自傳與學習計畫/短期學習計畫.pdf" --pdf-engine=pdflatex
pandoc "02_自傳與學習計畫/未來工作應用.md" -o "02_自傳與學習計畫/未來工作應用.pdf" --pdf-engine=pdflatex
```

### 步驟 3：合併 PDF 文件

使用預覽 app 或線上工具合併：

**使用預覽 app：**

1. 開啟第一個 PDF 文件
2. 拖拽其他 PDF 文件到側邊欄
3. 檔案 > 匯出為 PDF
4. 儲存為 `2025明緯獎學金-李沛宸.pdf`

**使用命令列：**

```bash
# 安裝 PDF 處理工具
brew install poppler

# 合併 PDF
pdfunite "01_申請書/300字短答_為何申請.pdf" \
         "02_自傳與學習計畫/自傳.pdf" \
         "02_自傳與學習計畫/短期學習計畫.pdf" \
         "02_自傳與學習計畫/未來工作應用.pdf" \
         "03_錄取在學證明/[證明文件].pdf" \
         "04_能力證明附錄/[證明文件].pdf" \
         "2025明緯獎學金-李沛宸.pdf"
```

## Windows 轉換與合併步驟

### 步驟 1：安裝必要工具

1. **安裝 Chocolatey**（Windows 套件管理器）

   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
   ```

2. **安裝 pandoc**

   ```powershell
   choco install pandoc
   ```

3. **安裝 MiKTeX**（LaTeX 發行版）
   - 前往 https://miktex.org/download 下載並安裝

### 步驟 2：轉換 Markdown 為 PDF

```powershell
# 進入申請包目錄
cd "2025_明緯獎學金_李沛宸"

# 轉換各個 Markdown 文件為 PDF
pandoc "01_申請書\300字短答_為何申請.md" -o "01_申請書\300字短答_為何申請.pdf" --pdf-engine=pdflatex
pandoc "02_自傳與學習計畫\自傳.md" -o "02_自傳與學習計畫\自傳.pdf" --pdf-engine=pdflatex
pandoc "02_自傳與學習計畫\短期學習計畫.md" -o "02_自傳與學習計畫\短期學習計畫.pdf" --pdf-engine=pdflatex
pandoc "02_自傳與學習計畫\未來工作應用.md" -o "02_自傳與學習計畫\未來工作應用.pdf" --pdf-engine=pdflatex
```

### 步驟 3：合併 PDF 文件

**使用線上工具：**

1. 前往 https://www.ilovepdf.com/merge-pdf
2. 上傳所有 PDF 文件
3. 調整順序
4. 下載合併後的 PDF，命名為 `2025明緯獎學金-李沛宸.pdf`

**使用 Adobe Acrobat：**

1. 開啟 Adobe Acrobat
2. 工具 > 合併檔案
3. 選擇所有 PDF 文件
4. 儲存為 `2025明緯獎學金-李沛宸.pdf`

## 注意事項

- 確保所有 Markdown 文件的中文顯示正常
- 檢查 PDF 轉換後的格式是否正確
- 確認最終合併的 PDF 檔名完全符合規範
- 建議在合併前先預覽所有單個 PDF 文件
- 最終 PDF 應為單一檔案，不能是多個檔案的壓縮包
