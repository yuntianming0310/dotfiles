vim.g.mapleader = " "

local keymap = vim.keymap

keymap.set("i", "jk", "<ESC>")

keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- keymap.set("n", "<leader>nh", ":nohl<CR>")

keymap.set("n", "<leader>h", ":bprevious<CR>")
keymap.set("n", "<leader>l", ":bnext<CR>")

-- keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Switch to previous buffer" })
-- keymap.set("n", "<leader>bb", ":bprevious<CR>", { desc = "Switch to next buffer" })

-- 插件快捷键
keymap.set("n", "<leader>b", ":NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })

-- 终端退出输入模式
keymap.set("t", "<esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- 格式化快捷键
keymap.set({ "n", "v" }, "<leader>p", function()
  require("conform").format({
    lsp_fallback = true,
    async = false,
    timeout_ms = 1000,
  })
end, { desc = "Format Code" })

-- 复制文件位置给 Agent CLI（支持普通模式单行和可视模式行范围）
keymap.set("n", "<leader>yr", function()
  local ref = string.format("@%s:L%d", vim.fn.expand("%:."), vim.fn.line("."))
  vim.fn.setreg("+", ref)
  vim.notify("Copied: " .. ref)
end, { desc = "Copy file:line for Agent" })

keymap.set("v", "<leader>yr", function()
  local s, e = vim.fn.line("v"), vim.fn.line(".")
  if s > e then
    s, e = e, s
  end
  local ref = string.format("@%s:L%d-L%d", vim.fn.expand("%:."), s, e)
  vim.fn.setreg("+", ref)
  vim.notify("Copied: " .. ref)
end, { desc = "Copy file:line range for Agent" })
