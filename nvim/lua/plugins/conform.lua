require("conform").setup({
  formatters_by_ft = {
    javascript = { "prettier" },
    typescript = { "prettier" },
    javascriptreact = { "prettier" },
    typescriptreact = { "prettier" },
    json = { "prettier" },
    html = { "prettier" },
    css = { "prettier" },
    markdown = { "prettier" },
    lua = { "stylua" },
    c = { "clang-format" },
    cpp = { "clang-format" },
    python = { "black" },
    rust = { "rustfmt" },
  },
  -- format_on_save = {
  --   lsp_fallback = true,
  --   timeout_ms = 1000,
  -- },
})