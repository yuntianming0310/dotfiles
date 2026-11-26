# my-nvim-setting

Minimal Neovim config based on lazy.nvim. Focus: theme, LSP, completion, formatting, file tree, search, Git.

`init.lua`
main entry that loads core and plugins

`lua/core/`
basic editor settings

- options.lua — options
- keymaps.lua — keymaps (leader = space, jk to escape)
- highlights.lua — diagnostics/float styles

`lua/plugins/`
all plugin configs

- plugins-setup.lua — lazy.nvim + plugin list
- catppuccin, nvim-tree, lualine, telescope, treesitter, mason, nvim-cmp, conform, gitsigns, comment, autopairs, bufferline, colorizer
- color theme: catppuccin

Quick tips

- place at `~/.config/nvim`, start Neovim to auto-install
- common: `:Lazy`, `:Mason`, `:TSUpdate`
- search needs ripgrep
- Live Server needs: `npm add -g live-server`