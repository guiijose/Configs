require "nvchad.options"

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!


vim.opt.tabstop = 4 -- number of spaces per tab characters
vim.opt.shiftwidth = 4 -- indentation width
vim.opt.expandtab = false -- use real tab characters
vim.opt.smartindent = true
vim.opt.exrc = true -- look for configurations in opened root (.nvim.lua)
vim.opt.gdefault = true -- fix :%s/old/new/g

vim.o.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  command = "checktime",
})

-- Disable inline diagnostic virtual text, keep signs and underlines
vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  float = {
    border = "rounded",
    source = "always", -- shows the source of the error (e.g., eslint, tsserver)
  },
})
