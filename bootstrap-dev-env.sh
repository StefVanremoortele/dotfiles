#!/usr/bin/env bash
#
# Bootstrap Dev Environment
# Installs zsh, oh-my-zsh, powerlevel10k, tmux, neovim with all configs
# 
# Usage: curl -fsSL https://raw.githubusercontent.com/YOUR_USER/dotfiles/main/bootstrap.sh | bash
# Or:    ./bootstrap-dev-env.sh [--root]
#
# Options:
#   --root    Also configure root user (requires sudo)
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }
info() { echo -e "${BLUE}[i]${NC} $1"; }

SETUP_ROOT=false
[[ "$1" == "--root" ]] && SETUP_ROOT=true

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    error "Cannot detect OS"
fi

info "Detected OS: $OS"
info "Setting up dev environment for user: $USER"

#######################
# Install packages
#######################

install_packages() {
    info "Installing packages..."
    
    case $OS in
        ubuntu|debian)
            sudo apt update
            sudo apt install -y zsh tmux neovim git curl wget unzip fontconfig
            ;;
        fedora)
            sudo dnf install -y zsh tmux neovim git curl wget unzip fontconfig
            ;;
        arch|manjaro)
            sudo pacman -Syu --noconfirm zsh tmux neovim git curl wget unzip fontconfig
            ;;
        *)
            warn "Unknown OS: $OS. Trying apt..."
            sudo apt update && sudo apt install -y zsh tmux neovim git curl wget unzip fontconfig
            ;;
    esac
    
    log "Packages installed"
}

#######################
# Oh My Zsh
#######################

install_ohmyzsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        warn "Oh My Zsh already installed, skipping..."
        return
    fi
    
    info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    log "Oh My Zsh installed"
}

#######################
# Powerlevel10k
#######################

install_p10k() {
    local P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    
    if [ -d "$P10K_DIR" ]; then
        warn "Powerlevel10k already installed, skipping..."
        return
    fi
    
    info "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
    log "Powerlevel10k installed"
}

#######################
# Zsh Plugins
#######################

install_zsh_plugins() {
    local CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    # zsh-autosuggestions
    if [ ! -d "$CUSTOM/plugins/zsh-autosuggestions" ]; then
        info "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$CUSTOM/plugins/zsh-autosuggestions"
    else
        warn "zsh-autosuggestions already installed"
    fi
    
    # zsh-syntax-highlighting
    if [ ! -d "$CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        info "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$CUSTOM/plugins/zsh-syntax-highlighting"
    else
        warn "zsh-syntax-highlighting already installed"
    fi
    
    log "Zsh plugins installed"
}

#######################
# Tmux Plugin Manager
#######################

install_tpm() {
    if [ -d "$HOME/.tmux/plugins/tpm" ]; then
        warn "TPM already installed, skipping..."
        return
    fi
    
    info "Installing Tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    log "TPM installed"
}

#######################
# Neovim (NvChad)
#######################

install_nvim_config() {
    if [ -d "$HOME/.config/nvim" ]; then
        warn "Neovim config exists, backing up..."
        mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak.$(date +%s)"
    fi
    
    info "Installing NvChad..."
    git clone https://github.com/NvChad/starter ~/.config/nvim
    log "NvChad installed (run nvim to complete setup)"
}

#######################
# Config Files
#######################

write_configs() {
    info "Writing config files..."
    
    # .zshrc
    cat > "$HOME/.zshrc" << 'ZSHRC'
# Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# PATH
export PATH="$HOME/.local/bin:$HOME/bin:$HOME/.npm-global/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# OpenClaw Completion
[[ -f "$HOME/.openclaw/completions/openclaw.zsh" ]] && source "$HOME/.openclaw/completions/openclaw.zsh"

# Powerlevel10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Aliases
[[ -f ~/.aliases ]] && source ~/.aliases
ZSHRC

    # .aliases
    cat > "$HOME/.aliases" << 'ALIASES'
# ~/.aliases - Shared aliases for bash and zsh

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias up="cd .."
alias home="cd ~"

# Listing
alias ls="ls --color=auto"
alias ll="ls -lh"
alias la="ls -lAh"
alias l="ls -CF"

# Editor
alias vi=nvim
alias vim=nvim

# Git
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git log --oneline -20"
alias gd="git diff"

# Safety
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"

# Grep
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"

# System
alias df="df -h"
alias du="du -h"
alias free="free -h"
alias ports="ss -tulnp"

# Shortcuts
alias c="clear"
alias h="history"
alias q="exit"
ALIASES

    # .tmux.conf
    cat > "$HOME/.tmux.conf" << 'TMUXCONF'
# Set prefix to Ctrl+A
set -g prefix C-a
unbind-key C-b
bind-key C-a send-prefix

# Plugin Options
set -g @catppuccin_flavor 'mocha'
set -g @catppuccin_window_status_style "rounded"
set -g status-right-length 100
set -g status-left-length 100
set -g status-left ""
set -g status-right "#{E:@catppuccin_status_application}"
set -agF status-right "#{E:@catppuccin_status_cpu}"
set -ag status-right "#{E:@catppuccin_status_session}"
set -ag status-right "#{E:@catppuccin_status_uptime}"
set -agF status-right "#{E:@catppuccin_status_battery}"

# Plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'christoomey/vim-tmux-navigator'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'catppuccin/tmux#v2.1.2'
set -g @plugin 'tmux-plugins/tmux-battery'
set -g @plugin 'tmux-plugins/tmux-cpu'

# Initialize TPM (keep at bottom of plugin section)
run '~/.tmux/plugins/tpm/tpm'

# Start windows and panes at 1
set -g base-index 1
set -g pane-base-index 1
set-window-option -g pane-base-index 1
set-option -g renumber-windows on

# Shift arrow to switch windows
bind -n S-Left  previous-window
bind -n S-Right next-window

# Vi mode
set-window-option -g mode-keys vi
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

# Splits keep current path
bind '"' split-window -v -c "#{pane_current_path}"
bind % split-window -h -c "#{pane_current_path}"

# Mouse
set -g mouse on

# Colors
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",xterm-256color:Tc"
set -ga terminal-overrides ",tmux-256color:Tc"
set-option -g default-command zsh

set -g window-style 'fg=colour230,bg=colour235'
set -g window-active-style 'fg=colour230,bg=colour233'

set -g pane-active-border-style 'fg=colour237,bg=colour234'
set -g pane-border-style 'fg=colour232,bg=colour234'
set -g pane-border-format '###{pane_index} [ #{pane_tty} ] S:#{session_name} M:#{pane_marked} #{pane_width}x#{pane_height}'
set -g pane-border-status 'bottom'

# Clear screen
unbind-key -n C-l
bind-key -n C-l send-keys C-l
TMUXCONF

    log "Config files written"
}

#######################
# Download p10k config
#######################

download_p10k_config() {
    info "Downloading Powerlevel10k config..."
    # Using a sensible default - user can run 'p10k configure' to customize
    if [ ! -f "$HOME/.p10k.zsh" ]; then
        curl -fsSL https://raw.githubusercontent.com/romkatv/powerlevel10k/master/config/p10k-rainbow.zsh > "$HOME/.p10k.zsh"
        log "p10k config downloaded (run 'p10k configure' to customize)"
    else
        warn "p10k config already exists"
    fi
}

#######################
# Set default shell
#######################

set_default_shell() {
    if [ "$SHELL" = "/usr/bin/zsh" ] || [ "$SHELL" = "/bin/zsh" ]; then
        warn "Zsh is already the default shell"
        return
    fi
    
    info "Setting zsh as default shell..."
    chsh -s "$(which zsh)" || warn "Could not change shell (run 'chsh -s /usr/bin/zsh' manually)"
}

#######################
# Setup root user
#######################

setup_root() {
    info "Setting up root user..."
    
    sudo cp -r "$HOME/.oh-my-zsh" /root/
    sudo cp "$HOME/.zshrc" "$HOME/.p10k.zsh" "$HOME/.tmux.conf" "$HOME/.aliases" /root/
    sudo mkdir -p /root/.config
    sudo cp -r "$HOME/.config/nvim" /root/.config/
    sudo cp -r "$HOME/.tmux" /root/
    sudo chsh -s "$(which zsh)" root || warn "Could not change root shell"
    
    log "Root user configured"
}

#######################
# Main
#######################

main() {
    echo ""
    echo "╔═══════════════════════════════════════╗"
    echo "║   Dev Environment Bootstrap Script    ║"
    echo "║          by Sudo @ firin              ║"
    echo "╚═══════════════════════════════════════╝"
    echo ""
    
    install_packages
    install_ohmyzsh
    install_p10k
    install_zsh_plugins
    install_tpm
    install_nvim_config
    write_configs
    download_p10k_config
    set_default_shell
    
    if [ "$SETUP_ROOT" = true ]; then
        setup_root
    fi
    
    echo ""
    echo "╔═══════════════════════════════════════╗"
    echo "║            Setup Complete!            ║"
    echo "╚═══════════════════════════════════════╝"
    echo ""
    log "Next steps:"
    echo "  1. Restart your terminal or run: exec zsh"
    echo "  2. Run 'p10k configure' to customize your prompt"
    echo "  3. Open tmux and press Ctrl+A then I to install plugins"
    echo "  4. Run 'nvim' to let Lazy.nvim install plugins"
    echo "  5. Install a Nerd Font for icons (e.g., MesloLGS NF)"
    echo ""
    
    if [ "$SETUP_ROOT" = false ]; then
        info "Run with --root to also configure the root user"
    fi
}

main "$@"
