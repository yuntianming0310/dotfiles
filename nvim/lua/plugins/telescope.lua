local telescope = require("telescope")
local builtin = require("telescope.builtin")

telescope.setup({
  defaults = {
    prompt_prefix = "   ",
    selection_caret = " ❯ ",
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    sorting_strategy = "ascending",
    layout_strategy = "horizontal",
    layout_config = {
      prompt_position = "top",
      preview_width = 0.55,
    },
  },
})

-- 进入telescope页面会是插入模式，回到正常模式就可以用j和k来移动了

vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find file" })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Find file globally" }) -- 环境里要安装ripgrep
vim.keymap.set('n', '<leader>fs', function()
  builtin.grep_string({ search = vim.fn.expand("<cword>") })
end, { desc = "Search current word globally" })
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
