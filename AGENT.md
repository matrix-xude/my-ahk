# AHK v2 Development Guide

## Environment
- Language: AutoHotkey (AHK)
- **STRICT VERSION CONSTRAINT: ALWAYS USE AHK v2 SYNTAX.** 
- **CRITICAL**: Never mix AHK v1 and v2 syntax. v1 code will cause syntax errors.

## Core v2 Coding Rules
- **Functions Over Commands**: Every action is a function. Parentheses `()` are REQUIRED (e.g., `Send("keys")`, `Click(x, y)`, `PixelGetColor(x, y)`).
- **No Commas After Command Names**: Never write `Send, keys`. Write `Send("keys")`.
- **Hotkeys Braces**: Multiline hotkeys must be enclosed in braces `{}`. Never use `Return` to end a hotkey.
- **Header Requirement**: Always include `#Requires AutoHotkey v2.0` at the very top of new scripts.
- **Variables**: Always use `:=` for assignment. Never use `=` for assignment.
- **Global Scope (CRITICAL)**: To modify or reference (via `&`) a global variable inside a function or hotkey, you MUST declare it with `global varName` on the first line of the block. Failure to do so with `&` references will cause "This parameter has not been assigned a value" errors.
- **Truthiness & Null Checks**: 
    - Use `if (result)` to check for objects or success. 
    - In AHK v2, `0`, `""` (empty string), and `unset` are **False**. 
    - Objects and non-zero numbers are **True**. 
    - Functions with no return value implicitly return `""`.
- **Block Braces (CRITICAL)**: Always use explicit `{}` braces for `if`, `else`, `loop`, etc., even for single-line statements. Do not write single-line inline if-statements (e.g., `if (x) doSomething()`) as it frequently causes `Unexpected "}"` parsing errors in AHK v2.

## Code Style Example (Strict v2)
```autohotkey
#Requires AutoHotkey v2.0

^1:: {
    if WinActive("ahk_exe chrome.exe") {
        color := PixelGetColor(100, 200)
        if (color == 0xFF0000) {
            ControlSend("3", , "ahk_exe chrome.exe")
        }
    }
}
```

## Anti-Patterns to Avoid (Never Output This!)

- `^1:: Send, keys \n Return` (Wrong! This is v1 style)
- `if color = 0xFF0000` (Wrong! Use `==`)
- `Variable = text` (Wrong! Use `:=`)
- `if (missing) MsgBox("Error")` (Wrong! Always use `{}` for the block: `if (missing) { MsgBox("Error") }`)