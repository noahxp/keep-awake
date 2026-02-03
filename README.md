# KeepAwake

macOS 狀態列（menu bar）應用程式，透過系統內建的 `caffeinate` 指令防止電腦進入睡眠。

## 環境要求

| 項目 | 版本 |
|------|------|
| macOS | 13 Ventura 以上 |
| Swift | 5.9 以上 |
| Xcode / CommandLineTools | 提供 Swift toolchain 即可 |

## 使用方式

點擊狀態列的咖啡杯圖標，從下拉選單中選擇欲設定的時間：

| 選項 | 持續時間 |
|------|----------|
| 5 分鐘 | 300 秒 |
| 30 分鐘 | 1,800 秒 |
| 1 小時 | 3,600 秒 |
| 2 小時 | 7,200 秒 |
| 3 小時 | 10,800 秒 |
| 5 小時 | 18,000 秒 |

- 目前正在運行的時間選項前會顯示勾號，方便一覽當前設定。
- 圖標在 caffeinate 運行時切換為 **cup.and.saucer.fill**，結束後回到 **cup.and.saucer**。
- 在已選中的時間內再次選擇其他時間，會自動先終止前一個再啟動新的。
- 倒計時滿後 caffeinate 自動退出，圖標同步切回咖啡杯，無需手動操作。
- 選單底部的「結束」選項會終止 caffeinate 並離開程序。

### 開機自動啟動

選單中的「開機執行」toggle 可設定是否在登入時自動啟動。透過 `SMAppService` 實現，勾選後系統會自動在登入時啟動 KeepAwake。

### 語言切換

支援以下四種語言，應用程式啟動時會自動檢測系統語言；不支援的語系會回退為英文。也可透過選單中的語言子選單手動切換：

| 語言 | 系統語言碼 |
|------|------------|
| 英文 | en |
| 繁體中文 | zh-TW、zh-HK |
| 简体中文 | zh-CN |
| 日本語 | ja |

## 開發入門

### 建構

```bash
swift build                          # debug
swift build --configuration release  # release
```

### 啟動（開發用）

```bash
./run.sh                          # debug build + 啟動
./run.sh --configuration release  # release build + 啟動
```

`run.sh` 會將 binary 組裝為 `.app` bundle（設定 `LSBackgroundOnly` 避免出現在 Dock）並透過 `open` 啟動，確保 MenuBarExtra 正常顯示於狀態列。

### 執行測試

```bash
swift run KeepAwakeTests
```

測試全部通過時退出碼為 `0`，有失敗時退出碼為 `1`。

> 本項目使用自定義輕量測試 harness 而非 XCTest 或 swift-testing。原因是在僅安裝 CommandLineTools（無 Xcode）的環境中，`XCTest` 框架不可用，而 `swift-testing` 的跨模組 overlay（`_Testing_Foundation`）缺少 `.swiftmodule`，無法被 SPM 解析。自定義 harness 僅依賴 Foundation，功能等價於上述兩個框架。

### 移除

```bash
./remove.sh
```

清除所有 KeepAwake 相關的配置與緩存，包括開機啟動的 LaunchAgent plist、從 DMG 安裝到 `/Applications` 的 `.app` bundle、`~/Library/Preferences` 裡的偏好設定、以及 `~/Library/Application Support` 和 `~/Library/Caches` 裡的緩存。

## 發布流程

透過 GitHub Actions 自動化發布（`.github/workflows/release.yml`）。當推送符合 `v*` 的 tag 時，會自動執行測試、release build、組裝 `.app`、打包為 DMG，並發布到 GitHub Releases：

```bash
git tag v1.0.0
git push origin v1.0.0
```

## 項目結構

```
keep-awake/
├── Package.swift                          # SPM 定義：三個 target
├── run.sh                                 # 開發用啟動腳本
├── remove.sh                              # 移除 app 及相關配置的腳本
├── .github/
│   └── workflows/
│       └── release.yml                    # GitHub Actions：自動發布 DMG
├── Sources/
│   ├── KeepAwake/                         # KeepAwakeLib — 核心業務函式庫
│   │   ├── Duration.swift                 # 時間選項數據模型
│   │   ├── ProcessRunner.swift            # ProcessRunner protocol + RealProcessRunner
│   │   ├── CaffeinateManager.swift        # caffeinate 生命週期管理（ObservableObject）
│   │   ├── LoginItemService.swift         # LoginItemService protocol + RealLoginItemService
│   │   ├── LoginItemManager.swift         # 開機自動啟動狀態管理（ObservableObject）
│   │   ├── Language.swift                 # 支援語言枚舉
│   │   ├── LocalizationManager.swift      # 國際化字串管理（ObservableObject）
│   │   └── MenuBarView.swift              # 狀態列下拉選單視圖
│   └── KeepAwakeApp/                      # KeepAwake — 程序入口點
│       └── KeepAwakeApp.swift             # @main，MenuBarExtra 場景
└── Tests/
    └── KeepAwakeTests/                    # KeepAwakeTests — 單元測試（33 個）
        ├── main.swift                     # 測試入口：登記並執行全部測試
        ├── TestHarness.swift              # 輕量測試框架（registerTest / assertEqual 等）
        ├── MockProcessRunner.swift        # ProcessRunner 的測試用 mock
        ├── MockLoginItemService.swift     # LoginItemService 的測試用 mock
        ├── DurationTests.swift            # Duration 數據模型測試（3 個）
        ├── CaffeinateManagerTests.swift   # CaffeinateManager 業務測試（16 個）
        ├── LoginItemManagerTests.swift    # LoginItemManager 業務測試（6 個）
        └── LocalizationManagerTests.swift # LocalizationManager 測試（8 個）
```

### SPM Target 說明

| Target | 類型 | 說明 |
|--------|------|------|
| `KeepAwakeLib` | `.target`（函式庫） | 所有業務邏輯與 UI，供入口點和測試共享 |
| `KeepAwake` | `.executableTarget` | 僅含 `@main` 入口，依賴 KeepAwakeLib |
| `KeepAwakeTests` | `.executableTarget` | 測試套件，依賴 KeepAwakeLib |

將業務代碼抽離為獨立函式庫 target 的原因：`.executableTarget` 產生的是可執行二進制，無法被其他 target `import`；透過 `.target` 輸出 `.swiftmodule`，測試 target 才能正常匯入公開類型。

## 架構說明

### 依賴注入與可測試性

核心業務類均不直接依賴系統服務，而是透過 protocol 隔離，並在 `init` 提供預設的生產實現，測試時注入 mock：

```swift
// CaffeinateManager：透過 processFactory 閉包取得 ProcessRunner
public init(processFactory: @escaping () -> ProcessRunner = { RealProcessRunner() })

// LoginItemManager：透過 service 參數取得 LoginItemService
public init(service: LoginItemService = RealLoginItemService())
```

- **生產環境**：預設值自動使用 `RealProcessRunner`（薄包裹 `Foundation.Process`）和 `RealLoginItemService`（薄包裹 `SMAppService`）。
- **測試環境**：注入 `MockProcessRunner` / `MockLoginItemService`，完全控制行為並記錄調用細節。

```
┌──────────────────┐  uses  ┌──────────────────┐
│ CaffeinateManager │──────►│  ProcessRunner   │ ← protocol
└──────────────────┘        └──────────────────┘
                                  ▲          ▲
                    ┌─────────────┘          └─────────────┐
                    ▼                                       ▼
         ┌─────────────────┐                ┌─────────────────────┐
         │ RealProcessRunner│               │  MockProcessRunner  │
         └─────────────────┘                └─────────────────────┘

┌──────────────────┐  uses  ┌──────────────────┐
│ LoginItemManager  │──────►│ LoginItemService │ ← protocol
└──────────────────┘        └──────────────────┘
                                  ▲          ▲
                    ┌─────────────┘          └─────────────┐
                    ▼                                       ▼
         ┌──────────────────┐              ┌─────────────────────┐
         │RealLoginItemService│            │ MockLoginItemService │
         └──────────────────┘              └─────────────────────┘
```

### 狀態同步

`caffeinate` 倒計時滿後會自動退出。`RealProcessRunner` 將 `Foundation.Process` 的 `terminationHandler` 轉接為自身的 `terminationHandler`，`CaffeinateManager` 在該回調中透過 `DispatchQueue.main.async` 將 `isRunning` 切為 `false`、`currentSeconds` 切為 `nil`，SwiftUI 的 `@Published` 自動驱動圖標與勾號的切換。

## 測試說明

共 **33 個單元測試**，按 TDD Red → Green 的順序開發：

| Wave | 測試內容 | 數量 |
|------|----------|------|
| 1 | Duration 數據模型（選項數量、秒數值、key 互不相同） | 3 |
| 2 | CaffeinateManager start 行為（executableURL、arguments、run 調用） | 3 |
| 3 | isRunning 狀態轉換（初始值、start 後、caffeinate 退出後） | 3 |
| 4 | stop 行為（terminate 調用、isRunning 切換、空狀態不崩潰） | 3 |
| 4.5 | currentSeconds 狀態（初始值、start 後、stop 後、退出後、切換後） | 5 |
| 5 | 重複啟動（切換時先終止前一個、新程序參數正確） | 2 |
| 6 | LoginItemManager（初始狀態、setEnabled、register/unregister 失敗處理） | 6 |
| 7 | LocalizationManager（初始化、切換語言、各語系字串查詢、系統語言檢測） | 8 |

`MockProcessRunner` 提供 `simulateTermination()` 方法，可在測試中手動觸發 `terminationHandler`，模擬 caffeinate 倒計時滿後自動退出的行為，無需等待真實程序。
