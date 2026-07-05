return {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      for _, source in ipairs(opts.sources) do
        if source.name == "nvim_lsp" then
          source.entry_filter = function(entry)
            return require("cmp").lsp.CompletionItemKind.Text ~= entry:get_kind()
          end
        end
      end
      return opts
    end,
  },

  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      git = {
        ignore = true,
      },
      filters = {
        custom = { "^.gitignore$" },
      },
      renderer = {
        group_empty = true, -- collapse folders with only one child
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },

  {
	  "lspcontainers/lspcontainers.nvim",
	  lazy = true,
  },

  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    ft = "rust",
    lazy = false,
    config = function()
      local configs = require "nvchad.configs.lspconfig"
      local on_attach = configs.on_attach
      local capabilities = configs.capabilities

      vim.g.rustaceanvim = {
        server = {
          on_attach = function(client, bufnr)
            on_attach(client, bufnr)
          end,
          capabilities = capabilities,
        },
      }
    end,
  },

  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
      "TmuxNavigatorProcessList",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  },

  {
    "kylechui/nvim-surround",
    version = "*",
    lazy = false,
    config = function()
      require("nvim-surround").setup()
    end,
  },

  {
    "mfussenegger/nvim-jdtls",
    lazy = true,
    ft = "java",
  },
  {
    "ThePrimeagen/vim-be-good",
    cmd = "VimBeGood",
  },
}
