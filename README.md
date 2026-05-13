# My Dotfiles 🔥

## What's inside
- **zsh** - Shell config with Oh My Zsh + Powerlevel10k
- **ghostty** - Terminal config with Catppuccin Mocha theme
- **p10k** - Powerlevel10k prompt config
- **helix** - Helix editor config with Java LSP
- **.gitconfig** - Git config with delta diffs (update email after cloning)
- **.gitignore** - Global gitignore
- **Brewfile** - All tools, one command

## Install on a new Mac
```bash
git clone https://github.com/Kalophain14/dotfiles ~/dotfiles
cd ~/dotfiles

# 1. Install all tools
brew bundle

# 2. Symlink all dotfiles
./config.sh
```

> **After cloning:** open `.gitconfig` and add your email address.

## Useful commands
- `help` - see all aliases
- `reload` - reload shell config
- `dotfiles` - open dotfiles in VS Code
- `lg` - lazygit TUI
- `ld` - lazydocker TUI
