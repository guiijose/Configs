# Complete Ubuntu 24.04 Setup Guide: Replicating macOS Dotfiles & Development Environment

This guide provides a step-by-step procedure to replicate your exact development setup on a clean install of **Ubuntu 24.04 LTS (Noble Numbat)**.

---

## Table of Contents
1. [Initial System Preparation & Prerequisites](#1-initial-system-preparation--prerequisites)
2. [Fonts: JetBrainsMono Nerd Font](#2-fonts-jetbrainsmono-nerd-font)
3. [Git, Git LFS, git-delta & lazygit](#3-git-git-lfs-git-delta--lazygit)
4. [Zsh (Z Shell) & Modern CLI Tools](#4-zsh-z-shell--modern-cli-tools)
5. [Alacritty Terminal Emulator](#5-alacritty-terminal-emulator)
6. [Neovim & NvChad Configuration](#6-neovim--nvchad-configuration)
7. [tmux & tmuxp](#7-tmux--tmuxp)
8. [Synchronizing Your Dotfiles Repository](#8-synchronizing-your-dotfiles-repository)
9. [Verification Checklist](#9-verification-checklist)

---

## 1. Initial System Preparation & Prerequisites

Update package indices and install base build tools, system utilities, and dependencies:

```bash
sudo apt update && sudo apt upgrade -y

# Essential build tools and utilities
sudo apt install -y \
  build-essential \
  curl \
  wget \
  git \
  unzip \
  tar \
  pkg-config \
  fontconfig \
  software-properties-common \
  ca-certificates \
  gnupg \
  ripgrep \
  fd-find \
  python3 \
  python3-pip \
  python3-venv \
  pipx
```

> [!NOTE]
> On Ubuntu, `fd` is packaged as `fdfind`. Ensure a standard `fd` symlink exists in `~/.local/bin`:
> ```bash
> mkdir -p ~/.local/bin
> ln -sf "$(which fdfind)" ~/.local/bin/fd
> ```

---

## 2. Fonts: JetBrainsMono Nerd Font

Your Alacritty configuration, Neovim icons (nvim-tree, statusline), Starship prompt, and Tmux status line require **JetBrainsMono Nerd Font**:

```bash
mkdir -p ~/.local/share/fonts
cd /tmp
curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
tar -xf JetBrainsMono.tar.xz -C ~/.local/share/fonts/
rm JetBrainsMono.tar.xz
fc-cache -fv
```

Verify font installation:
```bash
fc-list : family | grep -i "JetBrainsMono Nerd Font"
```

---

## 3. Git, Git LFS, git-delta & lazygit

### 3.1 Install Git, Git LFS & git-delta
Ubuntu 24.04 provides `git`, `git-lfs`, and `git-delta` in official repositories:

```bash
sudo apt install -y git git-lfs git-delta
git lfs install
```

### 3.2 Install lazygit
`lazygit` is used in your workflow and tmuxp layouts. Install the latest official 64-bit Linux release:

```bash
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')
LAZYGIT_ARCH=$(uname -m | sed -e 's/aarch64/arm64/')
curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${LAZYGIT_ARCH}.tar.gz"
tar -xf /tmp/lazygit.tar.gz -C /tmp lazygit
sudo install /tmp/lazygit -D -t /usr/local/bin/
rm -f /tmp/lazygit.tar.gz /tmp/lazygit
```

### 3.3 Configure `~/.gitconfig`
Write your global Git configuration with `delta` side-by-side pager and `diff3` conflict style:

```bash
cat << 'EOF' > ~/.gitconfig
[user]
	email = guilherme.a.jose@tecnico.ulisboa.pt
	name = guiijose
[filter "lfs"]
	clean = git-lfs clean -- %f
	smudge = git-lfs smudge -- %f
	process = git-lfs filter-process
	required = true
[core]
    pager = delta

[interactive]
    diffFilter = delta --color-only

[delta]
    navigate = true    # use n and N to move between diff sections
    side-by-side = true

[delta "lazygit"]
	side-by-side = false

[merge]
    conflictstyle = diff3

[diff]
    colorMoved = default
EOF
```

Configure global Git ignore:
```bash
mkdir -p ~/.config/git
echo '**/.claude/settings.local.json' > ~/.config/git/ignore
```

---

## 4. Zsh (Z Shell) & Modern CLI Tools

### 4.1 Install Zsh and Set as Default Shell
```bash
sudo apt install -y zsh
sudo chsh -s "$(which zsh)" "$USER"
```

### 4.2 Install CLI Tools: eza, bat, zoxide, fzf, starship, nvm

1. **eza (Modern replacement for `ls`)**:
   ```bash
   sudo mkdir -p /etc/apt/keyrings
   wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
   echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
   sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
   sudo apt update && sudo apt install -y eza
   ```

2. **bat (File previewer with syntax highlighting)**:
   ```bash
   sudo apt install -y bat
   # On Ubuntu, bat installs as batcat; symlink it to bat:
   mkdir -p ~/.local/bin
   ln -sf "$(which batcat)" ~/.local/bin/bat
   ```

3. **zoxide & fzf**:
   ```bash
   sudo apt install -y zoxide fzf
   ```

4. **Starship Prompt**:
   ```bash
   curl -sS https://starship.rs/install.sh | sh -s -- -y
   ```

5. **fzf-git.sh (Interactive Git widget)**:
   ```bash
   git clone https://github.com/junegunn/fzf-git.sh.git ~/fzf-git.sh
   ```

6. **Zsh Plugins (autosuggestions & syntax highlighting)**:
   ```bash
   sudo apt install -y zsh-autosuggestions zsh-syntax-highlighting
   ```

7. **NVM & Node.js (Prerequisite for Neovim LSP / Mason)**:
   ```bash
   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
   export NVM_DIR="$HOME/.nvm"
   [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
   nvm install --lts
   ```

### 4.3 Configure `~/.zshrc` (Linux-Adapted)
Your macOS `.zshrc` had Homebrew paths (`/opt/homebrew/...`) and macOS-specific environment variables. Use this Linux-adapted equivalent:

```bash
cat << 'EOF' > ~/.zshrc
export PATH="$HOME/.local/bin:$PATH"

export EDITOR='nvim'
export VISUAL='nvim'

autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# Use eza instead of ls
alias ls="eza --icons --group-directories-first"
alias ll="eza --icons --group-directories-first -l"
alias la="eza --icons --group-directories-first -la"

# Initialize Starship prompt
eval "$(starship init zsh)"

# Auto-start tmux session if not inside tmux
if [ -z "$TMUX" ]; then
    tmux new-session -A -s vittorio-codes
fi

# History configuration
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# Arrow-key history search
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# Zsh Autosuggestions (Ubuntu standard path)
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# zoxide (Smart cd)
eval "$(zoxide init zsh)"
alias cd="z"

# fzf
eval "$(fzf --zsh)"

# --- FZF Configuration ---
show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview \"$show_file_or_dir_preview\""
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \$'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

# fzf-git (Git shortcuts like Ctrl-G + H)
if [ -f ~/fzf-git.sh/fzf-git.sh ]; then
    source ~/fzf-git.sh/fzf-git.sh
    bindkey -r '^g^h'
    bindkey '^e' fzf-git-hashes-widget
fi

# Zsh Syntax Highlighting (Must be loaded last)
if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Node Version Manager (NVM)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF
```

### 4.4 Configure `~/.config/starship.toml`
```bash
cat << 'EOF' > ~/.config/starship.toml
# Insert a blank line between commands
add_newline = true

[package]
disabled = true

[character]
success_symbol = "[❯](bold green)"
error_symbol   = "[❯](bold red)"

[git_branch]
symbol = " "
style = "bold #ff69b4"

[directory]
style = "blue"
truncation_length = 3
truncate_to_repo = false

[docker_context]
disabled = true

[aws]
disabled = true

[gcloud]
disabled = true

[azure]
disabled = true
EOF
```

---

## 5. Alacritty Terminal Emulator

### 5.1 Install Alacritty
Ubuntu 24.04 includes Alacritty in the universe repository:
```bash
sudo apt install -y alacritty
```

*(Optional) Set Alacritty as your default X terminal:*
```bash
sudo update-alternatives --set x-terminal-emulator "$(which alacritty)"
```

### 5.2 Install Alacritty Themes
```bash
git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes
```

### 5.3 Configure `~/.config/alacritty/alacritty.toml` (Linux-Adapted)
> [!IMPORTANT]
> The macOS version contained `/Users/guilhermejose/...`, `decorations = "Buttonless"`, and `option_as_alt = "OnlyLeft"`.
> On Linux, the import path should use your Linux home directory, `decorations` should be set to `"Full"` or `"None"`, and `option_as_alt` is omitted.

```bash
cat << 'EOF' > ~/.config/alacritty/alacritty.toml
[general]
import = [
    # Uses relative or home-relative path
    "~/.config/alacritty/themes/themes/catppuccin.toml"
]

live_config_reload = true

[window]
decorations = "Full"
opacity = 1.0
padding = { x = 10, y = 0 }
dynamic_title = true

[font]
size = 16.0
offset = { y = 0 }

[font.normal]
family = "JetBrainsMono Nerd Font"
style = "Regular"

[font.bold]
family = "JetBrainsMono Nerd Font"
style = "Bold"

[font.italic]
family = "JetBrainsMono Nerd Font"
style = "Italic"

[env]
TERM = "xterm-256color"

[cursor]
style = { shape = "Block", blinking = "Off" }

[keyboard]
bindings = [
  { key = "Return", mods = "Shift", chars = "\u001b\r" }
]
EOF
```

---

## 6. Neovim & NvChad Configuration

### 6.1 Install Neovim (Latest Stable v0.10+)
> [!CAUTION]
> **Do NOT use `sudo apt install neovim` on Ubuntu 24.04.**
> Ubuntu 24.04 ships with Neovim 0.9.5 in apt. NvChad v2.5 and modern Tree-sitter parsers require **Neovim >= 0.10.0**.

Install the official pre-built Linux x86_64 tarball:

```bash
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
rm nvim-linux-x86_64.tar.gz
```

Verify version (should be v0.10.x or higher):
```bash
nvim --version
```

### 6.2 Install Neovim LSP / Tree-sitter Prereqs
Mason and Tree-sitter build tools require a C compiler, Node.js/npm, Python venv, and clangd:
```bash
sudo apt install -y clangd
```

### 6.3 Deploy Your Neovim Config
Your Neovim config uses NvChad v2.5 and custom plugins.
If you clone your dotfiles repository (see [Section 8](#8-synchronizing-your-dotfiles-repository)), `~/.config/nvim` will already be populated.

On first launch:
```bash
nvim
```
- `lazy.nvim` will automatically bootstrap.
- NvChad v2.5 core will clone.
- All plugins (`conform.nvim`, `rustaceanvim`, `vim-tmux-navigator`, `nvim-surround`, `nvim-jdtls`, `gitsigns.nvim`) will install automatically.
- Wait for the installations to finish, then quit with `:qa`.

---

## 7. tmux & tmuxp

### 7.1 Install tmux & tmuxp
```bash
sudo apt install -y tmux tmuxp
```

### 7.2 Install Oh My Tmux! (`gpakosz/.tmux`)
Your active tmux environment uses `Oh My Tmux!` with a Catppuccin theme:

```bash
git clone https://github.com/gpakosz/.tmux.git ~/.tmux
ln -s -f ~/.tmux/.tmux.conf ~/.tmux.conf
```

### 7.3 Configure `~/.tmux.conf.local`
Deploy your exact Catppuccin theme and custom keybindings:

```bash
cat << 'EOF' > ~/.tmux.conf.local
# : << 'EOF'
# Oh my tmux! Local Configuration (Catppuccin Theme)

tmux_conf_preserve_stock_bindings=false
tmux_conf_new_session_prompt=false
tmux_conf_new_session_retain_current_path=false
tmux_conf_new_window_retain_current_path=false
tmux_conf_new_window_reconnect_ssh=false
tmux_conf_new_pane_retain_current_path=true
tmux_conf_new_pane_reconnect_ssh=false
tmux_conf_24b_colour=auto

# Theme configuration
tmux_conf_theme=enabled
tmux_conf_theme_colour_1="#11111b"    # crust
tmux_conf_theme_colour_2="#313244"    # surface0
tmux_conf_theme_colour_3="#a6adc8"    # subtext0
tmux_conf_theme_colour_4="#8caaee"    # blue
tmux_conf_theme_colour_5="#f9e2af"    # yellow
tmux_conf_theme_colour_6="#11111b"    # crust
tmux_conf_theme_colour_7="#cdd6f4"    # text
tmux_conf_theme_colour_8="#11111b"    # crust
tmux_conf_theme_colour_9="#f9e2af"    # yellow
tmux_conf_theme_colour_10="#f5c2e7"   # pink
tmux_conf_theme_colour_11="#a6e3a1"   # green
tmux_conf_theme_colour_12="#a6adc8"   # subtext0
tmux_conf_theme_colour_13="#cdd6f4"   # text
tmux_conf_theme_colour_14="#11111b"   # crust
tmux_conf_theme_colour_15="#11111b"   # crust
tmux_conf_theme_colour_16="#f38ba8"   # red
tmux_conf_theme_colour_17="#cdd6f4"   # text

tmux_conf_theme_window_fg="default"
tmux_conf_theme_window_bg="default"
tmux_conf_theme_highlight_focused_pane=false
tmux_conf_theme_focused_pane_fg="default"
tmux_conf_theme_focused_pane_bg="$tmux_conf_theme_colour_2"
tmux_conf_theme_pane_border_style=thin
tmux_conf_theme_pane_border="$tmux_conf_theme_colour_2"
tmux_conf_theme_pane_active_border="$tmux_conf_theme_colour_4"
%if #{>=:#{version},3.2}
tmux_conf_theme_pane_active_border="#{?pane_in_mode,$tmux_conf_theme_colour_9,#{?synchronize-panes,$tmux_conf_theme_colour_16,$tmux_conf_theme_colour_4}}"
%endif

tmux_conf_theme_pane_indicator="$tmux_conf_theme_colour_4"
tmux_conf_theme_pane_active_indicator="$tmux_conf_theme_colour_4"
tmux_conf_theme_message_fg="$tmux_conf_theme_colour_1"
tmux_conf_theme_message_bg="$tmux_conf_theme_colour_5"
tmux_conf_theme_message_attr="bold"
tmux_conf_theme_message_command_fg="$tmux_conf_theme_colour_5"
tmux_conf_theme_message_command_bg="$tmux_conf_theme_colour_1"
tmux_conf_theme_message_command_attr="bold"
tmux_conf_theme_mode_fg="$tmux_conf_theme_colour_1"
tmux_conf_theme_mode_bg="$tmux_conf_theme_colour_5"
tmux_conf_theme_mode_attr="bold"
tmux_conf_theme_status_fg="$tmux_conf_theme_colour_3"
tmux_conf_theme_status_bg="$tmux_conf_theme_colour_1"
tmux_conf_theme_status_attr="none"
tmux_conf_theme_terminal_title="#h ❐ #S ● #I #W"
tmux_conf_theme_window_status_fg="$tmux_conf_theme_colour_3"
tmux_conf_theme_window_status_bg="$tmux_conf_theme_colour_1"
tmux_conf_theme_window_status_attr="none"
tmux_conf_theme_window_status_format="#I #W#{?#{||:#{window_bell_flag},#{window_zoomed_flag}}, ,}#{?window_bell_flag,!,}#{?window_zoomed_flag,Z,}"
tmux_conf_theme_window_status_current_fg="$tmux_conf_theme_colour_1"
tmux_conf_theme_window_status_current_bg="$tmux_conf_theme_colour_4"
tmux_conf_theme_window_status_current_attr="bold"
tmux_conf_theme_window_status_current_format="#I #W#{?#{||:#{window_bell_flag},#{window_zoomed_flag}}, ,}#{?window_bell_flag,!,}#{?window_zoomed_flag,Z,}"
tmux_conf_theme_window_status_activity_fg="default"
tmux_conf_theme_window_status_activity_bg="default"
tmux_conf_theme_window_status_activity_attr="underscore"
tmux_conf_theme_window_status_bell_fg="$tmux_conf_theme_colour_5"
tmux_conf_theme_window_status_bell_bg="default"
tmux_conf_theme_window_status_bell_attr="blink,bold"
tmux_conf_theme_window_status_last_fg="$tmux_conf_theme_colour_4"
tmux_conf_theme_window_status_last_bg="$tmux_conf_theme_colour_2"
tmux_conf_theme_window_status_last_attr="none"

tmux_conf_theme_left_separator_main='\uE0B4'
tmux_conf_theme_left_separator_sub='\uE0B5'
tmux_conf_theme_right_separator_main='\uE0B6'
tmux_conf_theme_right_separator_sub='\uE0B7'

tmux_conf_theme_status_left=" ❐ #S | ↑#{?uptime_y, #{uptime_y}y,}#{?uptime_d, #{uptime_d}d,}#{?uptime_h, #{uptime_h}h,}#{?uptime_m, #{uptime_m}m,} "
tmux_conf_theme_status_right=" #{prefix}#{mouse}#{pairing}#{synchronized}#{?battery_status, #{battery_status},}#{?battery_bar, #{battery_bar},}#{?battery_percentage, #{battery_percentage},} , %R , %d %b | #{username}#{root} "

tmux_conf_theme_status_left_fg="$tmux_conf_theme_colour_6,$tmux_conf_theme_colour_6,$tmux_conf_theme_colour_8"
tmux_conf_theme_status_left_bg="$tmux_conf_theme_colour_9,$tmux_conf_theme_colour_10,$tmux_conf_theme_colour_11"
tmux_conf_theme_status_left_attr="bold,none,none"
tmux_conf_theme_status_right_fg="$tmux_conf_theme_colour_12,$tmux_conf_theme_colour_14,$tmux_conf_theme_colour_14"
tmux_conf_theme_status_right_bg="$tmux_conf_theme_colour_15,$tmux_conf_theme_colour_16,$tmux_conf_theme_colour_17"
tmux_conf_theme_status_right_attr="none,none,bold"

# General preferences
set -g mouse on
set-option -g history-limit 50000
set -g default-terminal "screen-256color"
set-option -sa terminal-overrides ",xterm*:Tc"
set -s escape-time 0

# Split panes with current path
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
unbind '"'
unbind %

# Navigation & Reload
bind C-l send-keys 'C-l'
bind r source-file ~/.tmux.conf \; display "Config reloaded!"

# Plugins
tmux_conf_update_plugins_on_launch=true
tmux_conf_update_plugins_on_reload=true
tmux_conf_uninstall_plugins_on_reload=false

set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'christoomey/vim-tmux-navigator'
EOF
```

### 7.4 Configure `tmuxp` Profiles
Create `~/.tmuxp` and save your session templates:

```bash
mkdir -p ~/.tmuxp
```

Save `~/.tmuxp/openlsd.yaml`:
```yaml
session_name: openlsd
start_directory: ~/Repositories/openlsd

windows:
  - window_name: code
    panes:
      - nvim .
  - window_name: agy
    panes:
      - agy
  - window_name: Shell 1
    panes:
      - devcontainer up --workspace-folder . && devcontainer exec --workspace-folder . /bin/bash
  - window_name: Shell 2
    panes:
      - devcontainer up --workspace-folder . && devcontainer exec --workspace-folder . /bin/bash
  - window_name: Lazygit
    panes:
      - lazygit
```

> [!TIP]
> Notice the replacement of `open -a Docker` with standard Linux devcontainer startup commands, and `/Users/guilhermejose/...` with `~/Repositories/...`.

---

## 8. Synchronizing Your Dotfiles Repository

Your dotfiles are maintained at `git@github.com:guiijose/Configs.git`.

### 8.1 SSH Key Setup (for GitHub access)
If starting from a fresh Ubuntu machine:
```bash
ssh-keygen -t ed25519 -C "guilherme.a.jose@tecnico.ulisboa.pt"
cat ~/.ssh/id_ed25519.pub
# Add this public key to GitHub: Settings -> SSH and GPG keys
```

### 8.2 Clone to `~/.config`
```bash
# If ~/.config already exists, backup or clone into temporary directory
git clone git@github.com:guiijose/Configs.git /tmp/Configs
rsync -av /tmp/Configs/ ~/.config/
rm -rf /tmp/Configs

# Or clone directly if ~/.config is empty:
# git clone git@github.com:guiijose/Configs.git ~/.config
```

---

## 9. Verification Checklist

Run these commands in a new terminal session to confirm your setup:

| Tool | Verification Command | Expected Output |
| :--- | :--- | :--- |
| **Zsh** | `echo $SHELL` | `/usr/bin/zsh` |
| **Starship** | `starship --version` | `starship 1.x.x` |
| **Alacritty** | `alacritty --version` | `alacritty 0.13.x` |
| **Nerd Font** | `fc-match "JetBrainsMono Nerd Font"` | Font file in `.local/share/fonts` |
| **Neovim** | `nvim --version` | `NVIM v0.10.x` or `v0.11+` |
| **tmux** | `tmux -V` | `tmux 3.4` |
| **tmuxp** | `tmuxp --version` | `tmuxp 1.x.x` |
| **Git** | `git --version && git-lfs --version` | Version info for both |
| **Delta** | `delta --version` | `delta 0.16.x+` |
| **lazygit** | `lazygit --version` | `commit=..., version=...` |
| **eza** | `eza --version` | `v0.18.x+` |
| **bat** | `bat --version` | `bat 0.24.x+` |
| **zoxide** | `zoxide --version` | `zoxide 0.9.x+` |
| **fzf** | `fzf --version` | `0.48.x+` |
| **Node / NVM**| `nvm --version && node -v` | Active LTS node version |
