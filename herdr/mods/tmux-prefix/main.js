// 静默的 tmux 风格 prefix 按键拦截器（Ctrl-a 唤出，无可见浮条），
// 覆盖分屏、连续 resize、pane 交换、tab/space 切换等操作。

import { View, div } from "gpui-kit";
import { focused, run, hc, props, closeOverlay } from "herdr";

const RESIZE_STEP_PX = 40;
const RESIZE_TIMEOUT_MS = 800;

const MODIFIER_KEYS = new Set([
  "shift", "control", "ctrl", "alt", "option",
  "platform", "cmd", "meta", "super", "function", "capslock",
]);

const DIR_BY_HJKL = {
  h: "left",
  j: "down",
  k: "up",
  l: "right",
};

// 兼容不同键盘布局/事件字段，将带 Shift 的符号统一还原为字符
const SHIFT_KEY_FALLBACK = {
  "\\": "|",
  "4": "$",
  "9": "(",
  "0": ")",
  "/": "?",
};

function resolveChar(e) {
  if (e.key_char && e.key_char.length === 1) return e.key_char;
  const k = e.key ?? "";
  if (e.modifiers?.shift && SHIFT_KEY_FALLBACK[k]) return SHIFT_KEY_FALLBACK[k];
  return k.length === 1 ? k : "";
}

export default class TmuxPrefix extends View {
  init(_props, cx) {
    const cur = focused();
    this.targetTerminal = cur?.terminal ?? null;
    this.targetPane = cur?.pane ?? null;
    this.mode = "prefix"; // "prefix" | "resize"
    this.resizeGen = 0;
    this.busy = false;
    this.handle = cx.focus_handle();
    this.handle.focus();
  }

  close() {
    const id = props()?.overlay;
    if (id) closeOverlay(id);
  }

  paneArgs(extra = {}) {
    return this.targetPane ? { pane: this.targetPane, ...extra } : extra;
  }

  runAndClose(command, args) {
    this.close();
    run(command, args);
  }

  armResizeTimeout(cx) {
    const gen = ++this.resizeGen;
    cx.timer.after(RESIZE_TIMEOUT_MS, () => {
      if (this.mode === "resize" && this.resizeGen === gen) {
        this.close();
      }
    });
  }

  sendPrefix(cx) {
    if (this.busy) return;
    if (!this.targetTerminal) {
      this.close();
      return;
    }
    this.busy = true;
    // 必须先完成 hc keys 再关闭 overlay，避免视图销毁时提前取消异步任务
    const terminal = this.targetTerminal;
    cx.spawn(async () => {
      try {
        await hc(["keys", terminal, "ctrl+a"]);
      } finally {
        this.close();
      }
    });
  }

  onKeyDown(e, cx) {
    const rawKey = (e.key ?? "").toLowerCase();
    if (!rawKey || MODIFIER_KEYS.has(rawKey)) return;

    cx.stop_propagation();

    if (rawKey === "escape") {
      this.close();
      return;
    }

    const { shift = false, control = false, alt = false, platform = false } = e.modifiers ?? {};
    if (alt || platform) {
      this.close();
      return;
    }

    if (this.mode === "resize") {
      if (!control && !shift && DIR_BY_HJKL[rawKey]) {
        run("pane.resize", this.paneArgs({ direction: DIR_BY_HJKL[rawKey], px: RESIZE_STEP_PX }));
        this.armResizeTimeout(cx);
        return;
      }
      this.close();
      return;
    }

    if (control) {
      if (shift) {
        this.close();
        return;
      }
      if (rawKey === "a") {
        this.sendPrefix(cx);
        return;
      }
      if (DIR_BY_HJKL[rawKey]) {
        this.runAndClose("pane.swap", this.paneArgs({ direction: DIR_BY_HJKL[rawKey] }));
        return;
      }
      this.close();
      return;
    }

    const ch = resolveChar(e);

    if (ch === "|") return this.runAndClose("pane.split", this.paneArgs({ direction: "right" }));
    if (ch === "-" && !shift) return this.runAndClose("pane.split", this.paneArgs({ direction: "down" }));

    if (!shift && DIR_BY_HJKL[rawKey]) {
      this.mode = "resize";
      run("pane.resize", this.paneArgs({ direction: DIR_BY_HJKL[rawKey], px: RESIZE_STEP_PX }));
      this.armResizeTimeout(cx);
      return;
    }

    if (!shift && (rawKey === "m" || rawKey === "z")) return this.runAndClose("pane.zoom", this.paneArgs());
    if (!shift && rawKey === "c") return this.runAndClose("tab.new", {});
    if (!shift && rawKey === "n") return this.runAndClose("tab.next", {});
    if (!shift && rawKey === "p") return this.runAndClose("tab.prev", {});

    if (!shift && ch >= "1" && ch <= "9") {
      return this.runAndClose("tab.select", { index: Number(ch) });
    }

    if (ch === "," && !shift) return this.runAndClose("tab.rename", {});
    if (ch === "$") return this.runAndClose("space.rename", {});
    if (!shift && (rawKey === "s" || rawKey === "w")) return this.runAndClose("mod.open", { name: "picker" });
    if (ch === "(") return this.runAndClose("space.prev", {});
    if (ch === ")") return this.runAndClose("space.next", {});
    if (ch === "?") return this.runAndClose("app.help", {});

    this.close();
  }

  render() {
    return div()
      .id("tmux-prefix")
      .track_focus(this.handle)
      .on_key_down((e, cx) => this.onKeyDown(e, cx))
      .size_full();
  }
}
