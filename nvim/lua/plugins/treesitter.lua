local treesitter = require("nvim-treesitter")

treesitter.setup({
  install_dir = vim.fn.stdpath("data") .. "/site",
})

-- 自动补齐缺失的解析器；已有解析器通过 :TSUpdate 更新。
treesitter.install({
  "vim", "vimdoc", "bash", "c", "cpp", "javascript", "json", "lua", "python",
  "typescript", "tsx", "css", "html", "xml", "rust", "markdown", "markdown_inline",
})

-- 新版 nvim-treesitter 由 Neovim 内置接口启用语法高亮。
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("treesitter_highlight", { clear = true }),
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
    if lang and vim.treesitter.language.add(lang) then
      vim.treesitter.start(args.buf, lang)
    end
  end,
})
