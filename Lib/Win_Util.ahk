#Requires AutoHotkey v2.0

/**
 * 
 */
class WinUtil {
    
     /**
     * 展示自定义边界调试框
     */
    static ShowDebugBox(x, y, w, h, timeout := 2000) {
        try {
            debugGui := Gui("+AlwaysOnTop -Caption +ToolWindow -DPIScale")
            debugGui.BackColor := "Red"
            thickness := 2
            outerBox := "0-0 " w "-0 " w "-" h " 0-" h " 0-0"
            innerBox := thickness "-" thickness " " (w-thickness) "-" thickness " " (w-thickness) "-" (h-thickness) " " thickness "-" (h-thickness) " " thickness "-" thickness
            WinSetRegion(outerBox " " innerBox, debugGui.Hwnd)
            debugGui.Show("x" x " y" y " w" w " h" h " NoActivate")
            SetTimer(() => debugGui.Destroy(), -timeout)
        }
    }

     /**
     * 自定义调试点函数
     */
    static ShowDebugPoint(x, y, timeout := 2000) {
        this.ShowDebugBox(x - 2, y - 2, 4, 4, timeout)
    }
}
