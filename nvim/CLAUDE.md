# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal Neovim configuration built on top of [NvChad v2.5](https://github.com/NvChad/NvChad), which is loaded as a lazy.nvim plugin. NvChad provides the base UI, default keymaps, LSP defaults, and options — this repo only adds customizations on top.

## Formatting

Lua files are formatted with **stylua**. Config lives in `.stylua.toml`:
- 2-space indent, 120-column width, Unix line endings, double quotes.

To format a file: `stylua <file.lua>`

## Architecture

### Load order (`init.lua`)
1. `lazy.nvim` bootstraps itself, then loads NvChad (`NvChad/NvChad` branch `v2.5`) and local `plugins/`.
2. NvChad's base46 theme cache is dofile'd directly (fast path for colorscheme).
3. `options`, `autocmds`, and `mappings` are required last.

### Key files
- `lua/chadrc.lua` — NvChad UI overrides (theme: `tokyodark`, nvdash on startup).
- `lua/options.lua` — extends `nvchad.options`; sets 4-space-width real tabs, `exrc`, `gdefault`, and auto-reloads changed files on focus/cursor-hold.
- `lua/mappings.lua` — extends `nvchad.mappings`; adds `;` → `:`, `jk` → `<ESC>`, and Ctrl-hjkl tmux-navigator overrides.
- `lua/configs/lazy.lua` — lazy.nvim performance settings (all defaults lazy, several built-in vim plugins disabled).
- `lua/plugins/init.lua` — all plugin specs. Each plugin is either configured inline or delegates to a file under `lua/configs/`.
- `lua/configs/lspconfig.lua` — enables LSP servers: `html`, `cssls`, `clangd`, `pyright`, `protols`, `ts_ls`.
- `lua/configs/conform.lua` — formatter config (stylua for Lua; CSS/HTML prettier commented out; format-on-save disabled).
- `lua/configs/jdtls.lua` — Java LSP setup using sdkman Java at `~/.sdkman/candidates/java/current`. Workspace isolated per project under `stdpath("data")/site/java/workspace-root/<project>`.
- `ftplugin/java.lua` — auto-invokes `configs.jdtls.setup()` when a Java buffer opens.
- `templates/cp.cpp` — competitive programming C++ template, loaded via `:CppTemplate` command.

### Plugin highlights
- **rustaceanvim** — Rust LSP (replaces rust-tools); loaded lazily on `ft = "rust"`.
- **nvim-jdtls** — Java LSP; loaded lazily on `ft = "java"`, configured via `ftplugin/java.lua`.
- **conform.nvim** — formatting (format-on-save is currently commented out).
- **vim-tmux-navigator** — Ctrl-hjkl pane navigation, overrides NvChad defaults.
- **nvim-surround** — surround text objects.

## Adding / modifying things

- **New plugin**: add a spec to `lua/plugins/init.lua`; config goes in `lua/configs/<name>.lua` if non-trivial.
- **New LSP server**: add server name to the `servers` list in `lua/configs/lspconfig.lua`.
- **New keymap**: add to `lua/mappings.lua` using the local `map` alias.
- **Theme change**: edit `M.base46.theme` in `lua/chadrc.lua`. Available themes come from NvChad/base46.
- **Java JDK path**: update `java_cmd` in `lua/configs/jdtls.lua`.

## NvChad conventions

- Never require NvChad internals directly without prefixing with `nvchad.` (e.g. `require "nvchad.configs.lspconfig"`).
- `chadrc.lua` must mirror the structure of [`nvconfig.lua`](https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua).
- Plugin lazy-loading is on by default (`defaults = { lazy = true }` in `configs/lazy.lua`); set `lazy = false` only when needed.
