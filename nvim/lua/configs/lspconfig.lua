require("nvchad.configs.lspconfig").defaults()

local lspconfig = require("lspconfig")
local devcontainers = require("devcontainers")

local servers = { "html", "cssls", "clangd", "pyright", "protols", "ts_ls" }

for _, server in ipairs(servers) do
  local server_config = vim.lsp.config[server]
  if server_config and server_config.cmd then
    vim.lsp.config(server, {
      cmd = devcontainers.lsp_cmd(server_config.cmd)
    })
  end
end

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
