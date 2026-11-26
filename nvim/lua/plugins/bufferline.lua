vim.opt.termguicolors = true

local ok, ctp_bufferline = pcall(require, "catppuccin.special.bufferline")

require("bufferline").setup({
  highlights = ok and ctp_bufferline.get_theme() or nil,
  options = {
    -- 使用 nvim 内置lsp
    diagnostics = "nvim_lsp",
    separator_style = "thin",
    -- 左侧让出 nvim-tree 的位置
    offsets = {
      {
        filetype = "NvimTree",
        text = "File Explorer",
        highlight = "Directory",
        text_align = "left",
        separator = true,
      },
    },
  },
})
