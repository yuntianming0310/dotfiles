# Local Setup Notes

本机 Herdr app 定制偏好与已改动内容（修改配置前请先遵循以下约定）：

## 1. 快捷键（`keys.json` + `mods/tmux-prefix/`）
- 保留全部默认 macOS `Cmd-*` 快捷键。
- 在 `terminal` 作用域新增：
  - `ctrl-shift-h/j/k/l`：`pane.go:left/down/up/right`（保留小写 `ctrl-h/j/k/l` 给 nvim 和终端使用）。
  - `ctrl-a`：`mod.open:tmux-prefix`，进入 **静默无浮条** 的 tmux prefix 模式（`frame: "none"`, `1×1` 隐形 popup，不要改回可见浮条）。
- `tmux-prefix` 键位（不要加 `x`/`&` 关闭键或重复的方向切 Pane 键；暂不做 copy mode）：
  - `Ctrl-a`：透传 `ctrl+a` 给原终端（`hc keys <terminal> ctrl+a`）
  - `|` / `-`：向右 / 向下分屏
  - `h/j/k/l`：连续调整 Pane 大小（步长 40px，800ms 空闲或 `Esc` 退出）
  - `Ctrl-h/j/k/l`：向左 / 下 / 上 / 右交换 Pane
  - `m` / `z`：缩放 / 还原 Pane
  - `c` / `n` / `p` / `1`-`9`：新建 / 下一个 / 上一个 / 第 N 个 Tab
  - `,` / `$`：重命名 Tab / Space
  - `s` / `w`：打开 `picker`；`(` / `)`：上 / 下一个 Space；`?`：`app.help`；`Esc`：取消

## 2. 布局（`layouts/my-terminals.json`）
- 基于自带 `terminals` 布局克隆，默认使用 `my-terminals`。
- 焦点高亮与防抖约定：
  - `pane.border` 与 `pane.focus` 宽度保持一致（均为 `2px`），普通态为透明 `#00000000`，聚焦态为 `accent`（`#3b82f6`），避免切换焦点时内容区抖动。
  - `pane.veil: 0.3` 淡化非焦点 Pane。
