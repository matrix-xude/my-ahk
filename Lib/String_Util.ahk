#Requires AutoHotkey v2.0
#Include "Win_Util.ahk"
#Include "Vendor_OCR.ahk"

class StringUtil {
    /**
     * 在指定 Client 区域检测特定文字
     * @param {String} winTitle - 目标窗口标题/类名
     * @param {Integer} x, y, w, h - 搜索区域 (相对于 Client 坐标)
     * @param {String} text - 正则匹配文字 (例如 "点击空白区域关闭")
     * @returns {Object | False} - 成功返回 {x, y} (Client 中心坐标)，失败返回 False
     */
    static DetectText(winTitle, x, y, w, h, text) {
        if (!WinExist(winTitle)) {
            return false
        }

        ; 1. 获取窗口 Client 坐标偏移，用于 Screen 转换
        WinGetClientPos(&winCX, &winCY, , , winTitle)

        try {
            ; 2. 转换为 Screen 坐标供 OCR 使用
            screenX := winCX + x
            screenY := winCY + y
            ; 显示调试红框 1 秒，便于确认 OCR 识别区域
            WinUtil.ShowDebugBox(screenX, screenY, w, h, 1000)

            ; 3. 执行 OCR 识别 (使用简体中文)
            result := OCR.FromRect(screenX, screenY, w, h, "zh-Hans")
            OutputDebug(Format("【OCR识别结果】文本: '{1}'`n", result.Text))
            if (!result || result.Text == "") {
                return false
            }

            ; 4. 预处理文本：去掉所有空格、换行符、制表符
            cleanText := RegExReplace(result.Text, "\s+", "")
            searchText := RegExReplace(text, "\s+", "")
            if (searchText == "") {
                return false
            }

            ; 5. 构建正则 alternation，用一次匹配判断任一字符是否出现
            pattern := ""
            for index, ch in StrSplit(searchText)
            {
                escaped := RegExReplace(ch, "([.^$*+?()\[\]{}\\|])", "\\$1")
                pattern .= (pattern == "" ? "" : "|") . escaped
            }

            if (RegExMatch(cleanText, pattern)) {
                ; 获取识别到文字的实际外接矩形 (Screen 坐标)
                ; OCR.WordsBoundingRect 是 OCR.ahk 提供的工具函数
                rect := OCR.WordsBoundingRect(result.Words*)

                ; 6. 返回匹配文字的中心点 (转回 Client 坐标)
                return {
                    x: rect.x + (rect.w / 2) - winCX,
                    y: rect.y + (rect.h / 2) - winCY
                }
            }
        } catch Error as e {
            OutputDebug(Format("【OCR异常中断】原因: {1} (行号: {2})`n", e.Message, e.Line))
            return false
        }
        return false
    }
}
