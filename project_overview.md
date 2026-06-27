# AutoHotkey v2 Project Overview

This project is a structured **AutoHotkey v2** automation and hotkey script repository. It is designed to host scripts for multiple games, with a shared library (`Lib`) architecture and resolution-independent configurations.

---

## 📂 Project Directory Structure

Below is the directory layout of the workspace:

```
AHK_Project/
├── Lib/                      # Shared utility libraries
│   ├── Win_Util.ahk          # Debugging HUD UI utilities
│   ├── String_Util.ahk       # String and OCR utility helpers
│   └── Vendor_OCR.ahk        # UWP OCR engine wrapper
├── Game_YiHuan/              # Scripts specifically for the game "Yi Huan"
│   └── Fishing/              # Automation suite for the fishing minigame
│       ├── FishingEntry.ahk  # Entry point and loop runner (F5 / ESC)
│       ├── FishingBot.ahk    # Core class with detection and action logic
│       ├── config.ahk        # Configuration parameters and scale calculations
│       └── debug_*.ahk       # Step-by-step modular test scripts
├── Game_TianXia2/            # Scripts specifically for "Tian Xia 2"
│   └── Plant_Trees/          # Tree planting and sapling automation
│       └── obtain_sapling.ahk # Sapling automation script (F1 / F2 / ESC)
├── ARCHITECTURE.md           # Documentation on library resolution rules
└── AGENT.md                  # Development guide for strict AHK v2 coding
```

---

## 🛠️ Module Descriptions

### 1. 🎣 Yi Huan Fishing Bot (`Game_YiHuan/Fishing`)
A highly automated fishing bot that uses color detection and OCR to play the fishing minigame, handle inventory (selling fish), and purchase resources (bait).

*   **[FishingEntry.ahk](file:///D:/tools/hotkey/AHK_Project/Game_YiHuan/Fishing/FishingEntry.ahk)**:
    *   **F5**: Starts/Stops the fishing loop.
    *   **ESC**: Gracefully stops the program, reports statistics, and exits.
    *   **Workflow**:
        ```mermaid
        graph TD
            Start([Press F5]) --> Cast[Cast Line: Press F]
            Cast --> WaitHook{Wait for '鱼上钩了' OCR}
            WaitHook -- Timeout / Success --> Pull[Pull Rod: Press F]
            Pull --> DetectPlay{Detect Minigame Colors}
            DetectPlay -- Found L2 & L3 --> Fight[Update Movement: A / D]
            Fight --> DetectPlay
            DetectPlay -- Color Disappears --> WaitEnd{Wait for '点击空白区域关闭' OCR}
            WaitEnd --> ClickClose[Click to Close Interface]
            ClickClose --> Loop{Loop Running?}
            Loop -- Yes --> Cast
            Loop -- No --> Stop([Stop / ESC])
        ```
*   **[FishingBot.ahk](file:///D:/tools/hotkey/AHK_Project/Game_YiHuan/Fishing/FishingBot.ahk)**:
    *   `DetectColors`: Performs `PixelSearch` to locate the target green zone (L2) and player yellow indicator (L3).
    *   `UpdateMovement`: Implements a proportional-style control to hold key `a` or `d` to keep L3 inside L2.
    *   `SellFish` / `BuyFishBait`: Sequence of coordinate-based clicks to automate selling fish and buying bait.
*   **[config.ahk](file:///D:/tools/hotkey/AHK_Project/Game_YiHuan/Fishing/config.ahk)**:
    *   Hosts global variables: window titles, colors, key mappings, and target text zones.
    *   Contains pre-defined coordinate maps for **1920x1080** and **1280x720**.
    *   Includes `GetScaledConfig` to dynamically calculate coordinates for any other screen resolution based on aspect-ratio scaling.
*   **Debug Scripts (`debug_*.ahk`)**:
    *   Modular scripts allowing developers to test individual components like OCR text detection, player movement, single-cycle fishing, selling, or buying bait.

### 2. 🌳 Tian Xia 2 Sapling Collector (`Game_TianXia2`)
Automates collecting tree saplings ("摇钱树获取苗木") via OCR text detection and coordinate-offset clicking.

*   **[obtain_sapling.ahk](file:///D:/tools/hotkey/AHK_Project/Game_TianXia2/Plant_Trees/obtain_sapling.ahk)**:
    *   **F1**: Start search/click loop for "天宝阁", "宝鉴", "接受", "宝鉴摇钱树", and "完成". Repeats 19 times before exiting.
    *   **F2**: Debug full-screen search and show target clicks using `WinUtil.ShowDebugPoint`.
    *   **ESC**: Exit script.

### 3. 📚 Shared Libraries (`Lib`)
*   **[Win_Util.ahk](file:///D:/tools/hotkey/AHK_Project/Lib/Win_Util.ahk)**: Contains `WinUtil.ShowDebugBox`, which draws temporary red border frames on the screen using transparent GUI windows, assisting in checking OCR detection coordinates.
*   **[String_Util.ahk](file:///D:/tools/hotkey/AHK_Project/Lib/String_Util.ahk)**: Contains generic string/text automation helper functions like `StringUtil.DetectText`, which locates specific text in a target window's client area via OCR.
*   **[Vendor_OCR.ahk](file:///D:/tools/hotkey/AHK_Project/Lib/Vendor_OCR.ahk)**: A wrapper for the Windows UWP OCR engine (`Windows.Media.Ocr`), allowing extremely fast and localized character recognition without external DLL dependencies.

---

## 🔍 Key Architecture Details

> [!NOTE]
> **Library Inclusion Rules**
> In AutoHotkey v2, `#Include <LibName>` (using angle brackets) only searches the local `Lib` folder inside the *running script's directory* (i.e. `%A_ScriptDir%\Lib\`), the user library (`%A_MyDocuments%\AutoHotkey\Lib\`), and standard library.
> It does **not** search parent directories (like `..\Lib\`).
> Therefore, we use relative paths for files under `Game_YiHuan\Fishing\` to correctly target the root `Lib/` folder:
> *   `#Include "..\..\Lib\Win_Util.ahk"`
> *   `#Include "..\..\Lib\String_Util.ahk"`
> *   `#Include "..\..\Lib\Vendor_OCR.ahk"`

> [!NOTE]
> **AHK v2 Strict Syntax**
> As highlighted in [AGENT.md](file:///D:/tools/hotkey/AHK_Project/AGENT.md), this project strictly uses **AutoHotkey v2.0**.
> Remember to:
> 1. Use parentheses for all functions: e.g., `Send("keys")`.
> 2. Avoid using `Return` to end hotkeys; wrap multiline hotkeys in braces `{}`.
> 3. Use `:=` for assignment instead of `=`.
