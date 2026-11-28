local opt = vim.opt

-- 行号
opt.relativenumber = true
opt.number = true
opt.scrolloff = 5

-- 缩进
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- 自动折行：按单词折行，并保持续行缩进
opt.wrap = true
opt.linebreak = true
opt.breakindent = true

-- 光标行
opt.cursorline = true

-- 启用鼠标
opt.mouse:append("a")

-- 默认新窗口右和下
opt.splitright = true
opt.splitbelow = true

-- 搜索
opt.ignorecase = true
opt.smartcase = true

-- 外观
opt.termguicolors = true
opt.signcolumn = "yes"

-- 外部文件变动自动重载（配合 tmux + Agent CLI）
opt.autoread = true
opt.updatetime = 300

local agent_sync_group = vim.api.nvim_create_augroup("TmuxAgentSync", { clear = true })

-- 切出 Neovim（例如切到 tmux 里的 Agent CLI pane）时自动保存，避免双向冲突
vim.api.nvim_create_autocmd("FocusLost", {
  group = agent_sync_group,
  callback = function()
    if vim.bo.modified and not vim.bo.readonly and vim.bo.buftype == "" and vim.fn.expand("%") ~= "" then
      vim.cmd("silent! update")
    end
  end,
})

-- 切回 Neovim 或切换 buffer 时补检一次（覆盖不可见 buffer）
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  group = agent_sync_group,
  callback = function()
    if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
      vim.cmd("silent! checktime")
    end
  end,
})

-- 为 Markdown 文件设置特定的缩进
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.expandtab = true
  end,
})
