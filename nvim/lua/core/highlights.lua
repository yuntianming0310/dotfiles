vim.diagnostic.config({
  float = {
    border = "rounded",
  },
})

-- 统一浮窗、Telescope 边框与行号/光标行对比度，避免透明背景下浮窗边界模糊
local function apply_mocha_highlights()
  local ok, palettes = pcall(require, "catppuccin.palettes")
  if not ok then
    return
  end
  local c = palettes.get_palette("mocha")

  local set_hl = vim.api.nvim_set_hl
  set_hl(0, "NormalFloat", { bg = "NONE" })
  set_hl(0, "FloatBorder", { fg = c.lavender, bg = "NONE" })
  set_hl(0, "FloatTitle", { fg = c.lavender, bg = "NONE", bold = true })

  set_hl(0, "TelescopeNormal", { bg = "NONE" })
  set_hl(0, "TelescopeBorder", { fg = c.lavender, bg = "NONE" })
  set_hl(0, "TelescopePromptBorder", { fg = c.mauve, bg = "NONE" })
  set_hl(0, "TelescopeTitle", { fg = c.base, bg = c.lavender, bold = true })
  set_hl(0, "TelescopePromptTitle", { fg = c.base, bg = c.mauve, bold = true })

  set_hl(0, "WinSeparator", { fg = c.surface1 })
  set_hl(0, "LineNr", { fg = c.overlay0 })
  set_hl(0, "CursorLineNr", { fg = c.lavender, bold = true })
  set_hl(0, "CursorLine", { bg = c.surface0 })
end

apply_mocha_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("mocha_custom_highlights", { clear = true }),
  callback = apply_mocha_highlights,
})
