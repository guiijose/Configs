require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "clangd", "pyright", "protols", "ts_ls" }
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers 


--[[
-- lua/configs/lspconfig.lua
require("nvchad.lsp").diagnostic_config()  -- NvChad's defaults (already there)

vim.diagnostic.config({
  virtual_text = false,  -- your override
  signs = true,
  underline = true,
  severity_sort = true,
})
--]]
