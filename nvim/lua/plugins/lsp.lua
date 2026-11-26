require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})

require("mason-lspconfig").setup({
  -- 确保安装，根据需要填写
  ensure_installed = {
    "lua_ls",
    "ts_ls",
    "clangd",
    "marksman",
    "html",
    "cssls",
    "jsonls",
  },
})

-- 使用新 API：vim.lsp.config + vim.lsp.start
-- 参见 :help lspconfig-nvim-0.11
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- 定义一个 on_attach 函数，用于统一设置 LSP 快捷键
local on_attach = function(client, bufnr)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, buffer = bufnr, desc = "LSP: " .. desc })
  end

  map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
  map("n", "gr", vim.lsp.buf.references, "Go to References")
  map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
  map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
  map("n", "<leader>r", vim.lsp.buf.rename, "Rename Symbol")
  map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
  map("n", "<leader>e", vim.diagnostic.open_float, "Show Diagnostics")
end

-- 循环设置所有通过 mason-lspconfig 管理的 server（新式启动）
local servers = require("mason-lspconfig").get_installed_servers()
for _, server_name in ipairs(servers) do
  local cfg = vim.lsp.config(server_name, {
    on_attach = on_attach,
    capabilities = capabilities,
  })

  -- 为该 server 的 filetypes 创建自动启动
  if cfg and cfg.filetypes then
    local group = vim.api.nvim_create_augroup("lsp_autostart_" .. server_name, { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = cfg.filetypes,
      callback = function(args)
        -- 将当前 buffer 绑定到客户端配置并启动
        vim.lsp.start(vim.tbl_extend("force", cfg, { bufnr = args.buf }))
      end,
      desc = "Start LSP (" .. server_name .. ") via new API",
    })
  end
end
