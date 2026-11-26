# dotfiles

My personal dotfiles & macOS dev environment configs (Catppuccin Mocha dark setup).

## Structure

```text
dotfiles/
├── install.sh          # Idempotent symlink & iTerm2 sync installer
├── nvim/               # -> ~/.config/nvim
├── tmux/
│   └── tmux.conf       # -> ~/.tmux.conf
├── iterm2/             # Synced via iTerm2 PrefsCustomFolder
│   ├── com.googlecode.iterm2.plist
│   └── catppuccin-mocha.itermcolors
└── herdr/              # User-owned Herdr configs -> ~/.config/herdr-app/*
    ├── settings.json
    ├── keys.json
    ├── AGENTS.local.md
    ├── layouts/my-terminals.json
    └── mods/tmux-prefix/
```

## Quick Setup (New Machine)

```bash
git clone https://github.com/yuntianming0310/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

Existing files or directories are automatically backed up to `~/.dotfiles_backup/<timestamp>/` before linking.

## Adding New App Configs

1. Create a directory under `~/dotfiles/<app>/`.
2. Add a `link_path` entry in `install.sh` and re-run `./install.sh`.
3. Commit and push from `~/dotfiles`.
