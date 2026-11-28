local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
  return
end

local snip_status_ok, luasnip = pcall(require, "luasnip")
if not snip_status_ok then
  return
end

require("luasnip.loaders.from_vscode").lazy_load()

-- 下面会用到这个函数
local check_backspace = function()
  local col = vim.fn.col "." - 1
  return col == 0 or vim.fn.getline("."):sub(col, col):match "%s"
end


cmp.setup({
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },

  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },

  -- 自动触发补全
  completion = {
    autocomplete = {
      require('cmp.types').cmp.TriggerEvent.TextChanged,
    },
    completeopt = 'menu,menuone,noinsert',
  },

  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-e>'] = cmp.mapping.abort(), -- 取消补全，esc也可以退出

    -- 手动触发补全
    ['<C-n>'] = cmp.mapping.complete(), -- Ctrl+n 触发补全
    ['<C-j>'] = cmp.mapping.complete(), -- Ctrl+j 触发补全(备选)

    ['<CR>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        if cmp.get_selected_entry() then
          cmp.confirm({ select = true })
        else
          cmp.close()
          fallback()
        end
      else
        fallback()
      end
    end, { "i", "s" }),

    -- Tab键仅用于补全选项切换
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.locally_jumpable(1) then
        luasnip.jump(1)
      elseif check_backspace() then
        fallback()
      else
        fallback()
      end
    end, {
      "i",
      "s",
    }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, {
      "i",
      "s",
    }),
  }),

  -- 这里重要
  sources = cmp.config.sources({
    { name = 'nvim_lsp', priority = 1000 },
    { name = 'luasnip', priority = 750 },
    { name = 'path', priority = 500 },
  }, {
    { name = 'buffer', priority = 250 },
  })
})

-- 自动退出snippet：当离开snippet区域时自动取消snippet状态
vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
  callback = function()
    if luasnip.session.current_nodes[vim.api.nvim_get_current_buf()] and not luasnip.session.jump_active then
      luasnip.unlink_current()
    end
  end,
})
