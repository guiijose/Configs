# Copilot Instructions for This Repository

## Build, Test, and Lint Commands
- **Formatting:** Lua files are formatted with [stylua](https://github.com/JohnnyMorganz/StyLua). Run: `stylua <file.lua>`
- **Lint/Test:** No automated test or lint commands are defined in this config repo. Formatting is the main check.

## High-Level Architecture
- This is a personal Neovim configuration built on top of [NvChad v2.5](https://github.com/NvChad/NvChad), loaded as a lazy.nvim plugin.
- `init.lua` bootstraps lazy.nvim, loads NvChad, then local plugins and config files.
- Key config files:
  - `lua/chadrc.lua`: NvChad UI/theme overrides
  - `lua/options.lua`: Extends `nvchad.options`, sets tabs, exrc, gdefault, autoread
  - `lua/mappings.lua`: Extends `nvchad.mappings`, adds custom keymaps, tmux navigation
  - `lua/plugins/init.lua`: All plugin specs, with config in `lua/configs/` as needed
  - `lua/configs/lspconfig.lua`: LSP servers enabled (html, cssls, clangd, pyright, protols, ts_ls)
  - `lua/configs/jdtls.lua`: Java LSP setup (uses sdkman Java, per-project workspace)
  - `ftplugin/java.lua`: Auto-invokes Java LSP setup on Java buffers
  - `templates/cp.cpp`: C++ template for competitive programming, loaded via `:CppTemplate`

## Key Conventions
- **NvChad as a plugin:** Always require NvChad modules with `nvchad.` prefix (e.g., `require "nvchad.options"`).
- **Formatting:** 2-space indent, 120-column width, Unix line endings, double quotes (see `.stylua.toml`).
- **Plugin lazy-loading:** Default is lazy; set `lazy = false` only when needed.
- **Theme:** Set in `chadrc.lua` (`M.base46.theme`).
- **Java LSP:** Uses sdkman Java at `~/.sdkman/candidates/java/current`.
- **Competitive programming:** Use `:CppTemplate` to insert the C++ template into the current buffer.
- **Auto-reload:** Files auto-reload on focus/cursor-hold via autocmd in `options.lua`.
- **Keymaps:**
  - `;` enters command mode
  - `jk` exits insert mode
  - `<C-h/j/k/l>` navigates tmux panes

## Integration with Other AI Assistants
- See `CLAUDE.md` for Claude/OpenCode conventions and architecture notes. Follow its guidance for file structure, plugin management, and formatting.

---

Would you like to configure any MCP servers (e.g., Playwright for web projects) for this repository?

Let me know if you want to adjust anything or add coverage for additional areas.