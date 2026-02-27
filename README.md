# Dev Environment Bootstrap

A one-command setup for a consistent development environment across all your servers.

## Quick Start

```bash
# On a new server
curl -fsSL https://raw.githubusercontent.com/StefVanremoortele/dotfiles/main/bootstrap-dev-env.sh | bash

# Or copy and run manually
scp bootstrap-dev-env.sh user@newserver:~
ssh user@newserver "./bootstrap-dev-env.sh"
```

## What Gets Installed

| Tool | Description |
|------|-------------|
| **zsh** | Modern shell with better completion and scripting |
| **Oh My Zsh** | Framework for managing zsh configuration |
| **Powerlevel10k** | Fast, customizable zsh prompt theme |
| **zsh-autosuggestions** | Fish-like autosuggestions as you type |
| **zsh-syntax-highlighting** | Syntax highlighting for commands |
| **tmux** | Terminal multiplexer for persistent sessions |
| **TPM** | Tmux Plugin Manager |
| **Catppuccin** | Aesthetic tmux theme (mocha flavor) |
| **Neovim** | Modern vim with Lua config |
| **NvChad** | Neovim configuration framework |

## Usage

```bash
# Basic usage (current user only)
./bootstrap-dev-env.sh

# Also configure root user
./bootstrap-dev-env.sh --root
```

## Requirements

- Debian/Ubuntu, Fedora, or Arch-based Linux
- `sudo` access for package installation
- Internet connection for downloading plugins

## Configuration Files

The script creates these config files:

| File | Purpose |
|------|---------|
| `~/.zshrc` | Zsh configuration with oh-my-zsh |
| `~/.p10k.zsh` | Powerlevel10k prompt settings |
| `~/.tmux.conf` | Tmux configuration with plugins |
| `~/.aliases` | Shell aliases (works in bash and zsh) |
| `~/.config/nvim/` | Neovim configuration (NvChad) |

## Post-Install Steps

After running the script:

1. **Restart terminal** or run `exec zsh`

2. **Customize prompt** (optional):
   ```bash
   p10k configure
   ```

3. **Install tmux plugins**:
   - Open tmux: `tmux`
   - Press `Ctrl+A` then `I` (capital i)
   - Wait for plugins to install

4. **Install neovim plugins**:
   ```bash
   nvim
   # Wait for Lazy.nvim to install plugins
   # Press 'q' to close the installer window
   ```

5. **Install a Nerd Font** (for icons):
   - Download [MesloLGS NF](https://github.com/romkatv/powerlevel10k#manual-font-installation)
   - Set it as your terminal font

## Key Bindings

### Tmux (prefix: `Ctrl+A`)

| Binding | Action |
|---------|--------|
| `Ctrl+A` | Prefix key (instead of Ctrl+B) |
| `Shift+Left/Right` | Switch windows |
| `Ctrl+A "` | Split pane horizontally |
| `Ctrl+A %` | Split pane vertically |
| `Ctrl+A I` | Install plugins (TPM) |
| `Ctrl+A r` | Reload config |

### Neovim

| Binding | Action |
|---------|--------|
| `Space` | Leader key |
| `Space + f + f` | Find files |
| `Space + f + w` | Find word (grep) |
| `Space + c + h` | Cheatsheet |

## Aliases

```bash
# Navigation
..          # cd ..
...         # cd ../..

# Listing
ll          # ls -lh
la          # ls -lAh

# Git
gs          # git status
ga          # git add
gc          # git commit
gp          # git push
gl          # git log --oneline -20

# Editor
vi/vim      # nvim

# System
ports       # ss -tulnp
```

## Customization

### Change p10k theme
```bash
p10k configure
```

### Change tmux theme
Edit `~/.tmux.conf` and change:
```bash
set -g @catppuccin_flavor 'mocha'  # Options: latte, frappe, macchiato, mocha
```

### Add more zsh plugins
Edit `~/.zshrc` and add to the plugins array:
```bash
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  docker           # Add this
  kubectl          # Add this
)
```

## Troubleshooting

### Icons not showing
Install a [Nerd Font](https://www.nerdfonts.com/) and set it in your terminal.

### Tmux plugins not loading
Run inside tmux:
```bash
~/.tmux/plugins/tpm/bin/install_plugins
```

### Neovim errors on first run
This is normal - Lazy.nvim is installing plugins. Wait for it to complete.

### Permission denied
Make sure the script is executable:
```bash
chmod +x bootstrap-dev-env.sh
```

## Updating

To update plugins:

```bash
# Oh My Zsh
omz update

# Tmux plugins (inside tmux)
# Ctrl+A then U

# Neovim plugins (inside nvim)
:Lazy update
```

## Uninstall

```bash
# Remove oh-my-zsh
rm -rf ~/.oh-my-zsh

# Remove tmux plugins
rm -rf ~/.tmux

# Remove neovim config
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim

# Remove config files
rm ~/.zshrc ~/.p10k.zsh ~/.tmux.conf ~/.aliases

# Change shell back to bash
chsh -s /bin/bash
```

---

*Created by Sudo @ firin* 🔧
