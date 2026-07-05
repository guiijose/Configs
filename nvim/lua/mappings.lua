require "nvchad.mappings"

local map = vim.keymap.set

-- Custom mappings
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- TmuxNavigator mappings (FORCE these to override defaults)
map("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>", { desc = "window left" })
map("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>", { desc = "window down" })
map("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>", { desc = "window up" })
map("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", { desc = "window right" })



local diag_vtext_on = false

map("n", "<leader>dv", function()
  diag_vtext_on = not diag_vtext_on
  vim.diagnostic.config({ virtual_text = diag_vtext_on })
end, { desc = "Toggle diagnostic virtual text" })
