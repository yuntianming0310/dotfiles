#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_ROOT="$HOME/.dotfiles_backup/$(date +%Y%m%d%H%M%S)"

link_path() {
  local src="$1"
  local dst="$2"

  mkdir -p "$(dirname "$dst")"

  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "✓ already linked: $dst -> $src"
    return
  fi

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    # 集中备份到 ~/.dotfiles_backup，避免在 mods/ 或 layouts/ 等扫描目录内留下 .bak 干扰软件加载
    local rel="${dst#"$HOME/"}"
    local backup="$BACKUP_ROOT/$rel"
    mkdir -p "$(dirname "$backup")"
    mv "$dst" "$backup"
    echo "↺ backed up: $dst -> $backup"
  fi

  ln -s "$src" "$dst"
  echo "→ linked: $dst -> $src"
}

# Neovim
link_path "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

# tmux
link_path "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"

# Herdr（仅软链用户自定义配置，避开内置 mods 与运行态文件）
link_path "$DOTFILES_DIR/herdr/settings.json" "$HOME/.config/herdr-app/settings.json"
link_path "$DOTFILES_DIR/herdr/keys.json" "$HOME/.config/herdr-app/keys.json"
link_path "$DOTFILES_DIR/herdr/AGENTS.local.md" "$HOME/.config/herdr-app/AGENTS.local.md"
link_path "$DOTFILES_DIR/herdr/layouts/my-terminals.json" "$HOME/.config/herdr-app/layouts/my-terminals.json"
link_path "$DOTFILES_DIR/herdr/mods/tmux-prefix" "$HOME/.config/herdr-app/mods/tmux-prefix"

# iTerm2（使用原生 PrefsCustomFolder 同步，避免 cfprefsd 覆盖软链接）
if [ "$(uname -s)" = "Darwin" ]; then
  defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$DOTFILES_DIR/iterm2"
  defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
  echo "✓ configured iTerm2 PrefsCustomFolder -> $DOTFILES_DIR/iterm2"
fi

echo "Done. Restart iTerm2 if preferences were updated."
