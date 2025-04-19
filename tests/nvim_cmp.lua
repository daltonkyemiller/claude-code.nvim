#!/usr/bin/env -S nvim -l

vim.env.LAZY_STDPATH = ".tests"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

-- set leader key
vim.g.mapleader = " "

-- Setup lazy.nvim
require("lazy.minit").repro({
  spec = {
    {
      dir = ".",
      event = "VeryLazy",
      opts = {
        -- debug = true,
        window = {
          -- position = "float",
          width = 40,
        },
        keymaps = {
          arrow_down = {
            i = "none",
          },
          arrow_up = {
            i = "none",
          },
          arrow_left = {
            i = "none",
          },
          arrow_right = {
            i = "none",
          },
        },
        experimental = {
          hide_input_box = true,
        },
      },
      keys = {
        {
          "<leader>cc",
          function() require("claude-code.commands").toggle() end,
        },
        {
          "<leader>cF",
          function() require("claude-code.commands").focus() end,
        },
      },
    },
    { -- Autocompletion
      "hrsh7th/nvim-cmp",
      event = "InsertEnter",
      dependencies = {
        "hrsh7th/cmp-path",
      },
      config = function()
        local cmp = require("cmp")

        cmp.setup({
          snippet = {
            expand = function(args) end,
          },
          completion = { completeopt = "menu,menuone,noinsert" },

          mapping = cmp.mapping.preset.insert({
            ["<C-j>"] = cmp.mapping.select_next_item(),
            ["<C-k>"] = cmp.mapping.select_prev_item(),
            ["<Tab>"] = cmp.mapping.confirm({ select = true }),
          }),
          sources = {
            { name = "path" },
          },
        })
      end,
    },
  },
})
