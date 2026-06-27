# 项目架构与设计指南

本文档详细说明了 **AHK_Project** 工作区的目录结构、类库引用规则以及核心架构模式。

---

## 📂 项目目录结构

该项目旨在独立管理多个游戏的自动化脚本，同时共享一个通用的公用类库文件夹（`Lib`）：

```
AHK_Project/
├── Lib/                      # 共享的全局公共类库
│   ├── Win_Util.ahk          # 窗口操作与视觉调试覆盖层工具 (类名: WinUtil)
│   ├── String_Util.ahk       # 字符串自动化与 OCR 文本匹配工具 (类名: StringUtil)
│   └── Vendor_OCR.ahk        # 第三方 UWP OCR 引擎封装库 (类名: OCR)
├── Game_YiHuan/              # “异环” 游戏脚本套件
│   └── Fishing/              # 钓鱼小游戏自动化
│       ├── FishingEntry.ahk  # 脚本入口点，循环与热键绑定 (F5 / ESC)
│       ├── FishingBot.ahk    # 核心博弈逻辑 (颜色检测与游戏按键控制)
│       └── config.ahk        # 分辨率坐标配置 (1920x1080, 1280x720) 与通用配置选项
├── Game_TianXia2/            # “天下贰” 游戏脚本套件
│   └── Plant_Trees/          # 种植树木与获取苗木自动化
│       └── obtain_sapling.ahk # 获取苗木自动化脚本 (F1 / F2 / ESC)
├── ARCHITECTURE.md           # 本架构设计文档
└── AGENT.md                  # 严格的 AHK v2 开发规范与防错指南
```

---

## 🔗 类库引用规则与指南

在 AutoHotkey v2 中，引入 `Lib/` 文件夹下的共享类库有一套明确的寻址规则，决定了何时使用**相对路径**或**尖括号 `<>`**。

### 1. 相对路径引用 (推荐用于子目录)
对于存放在游戏子目录（如 `Game_YiHuan/Fishing/` 或 `Game_TianXia2/Plant_Trees/`）中的脚本，我们建议使用带双引号的**显式相对路径**来引用 `Lib` 工具。

**以 `FishingBot.ahk` 中的引用为例：**
```autohotkey
#Requires AutoHotkey v2.0
#Include "config.ahk"
#Include "..\..\Lib\Win_Util.ahk"      ; 相对于当前脚本目录的相对路径
#Include "..\..\Lib\String_Util.ahk"   ; 相对于当前脚本目录的相对路径
```

### 2. 尖括号引用 (`#Include <LibName>`)
使用 `#Include <Win_Util>`（尖括号包裹）时，AutoHotkey v2 **仅会**在以下三个标准路径中按顺序寻找名为 `Win_Util.ahk` 的文件：
1. `%A_ScriptDir%\Lib\`（与当前执行脚本同级目录下的 `Lib` 文件夹）。
2. `%A_MyDocuments%\AutoHotkey\Lib\`（系统用户的“文档”公共库目录）。
3. `[AutoHotkey.exe 所在目录]\Lib\`（AHK 安装路径下的标准库目录）。

> [!IMPORTANT]
> **尖括号引用无法向上搜寻父级目录**：AutoHotkey v2 在解析尖括号 `#Include <LibName>` 时，**不会**去上级目录（如 `..\Lib\`）中寻找。因此，为了确保脚本在各自的游戏目录下能被直接独立运行，所有处于子目录内的脚本必须使用相对路径形式引入类库。

### 3. 动态函数自动加载 (无需 #Include 声明)
如果您在脚本中直接调用了某个未被包含或定义的函数（例如直接调用了 `MyFunction()`），AutoHotkey v2 会尝试自动在 `Lib` 文件夹中寻找对应的同名文件并加载。
**仅针对这种无 `#Include` 的函数自动加载模式**，AHK v2 会递归向上搜索目录树：
*   `%A_ScriptDir%\Lib\MyFunction.ahk`
*   `%A_ScriptDir%\..\Lib\MyFunction.ahk` (上级父目录的 Lib)
*   `%A_ScriptDir%\..\..\Lib\MyFunction.ahk` (上上级祖父目录的 Lib —— **最多向上搜索 2 层**)

---

## ⚙️ 统一开发规范
1. **文件与类名大小写风格**：
   * `Lib/` 下的文件统一采用 **蛇形命名法 (snake_case)**（如 `Win_Util.ahk`、`String_Util.ahk`）。
   * 第三方库统一以 `Vendor_` 开头命名（如 `Vendor_OCR.ahk`）。
   * 文件内声明的全局类（Class）统一采用 **大驼峰命名法 (CamelCase)**（如 `WinUtil`、`StringUtil`、`OCR`）。
2. **路径归一化**：
   * 在使用外部安全沙箱或命令行运行脚本时，绝对路径的斜杠与大小写匹配可能失效。应尽量使用环境变量 `PATH` 动态指定 AHK 的执行路径，避免硬编码物理绝对路径（例如使用 `AutoHotkey64.exe` 代替 `D:\path\to\AutoHotkey64.exe`）。
