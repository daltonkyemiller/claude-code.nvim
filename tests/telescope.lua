#!/usr/bin/env -S nvim -l

vim.env.LAZY_STDPATH = ".tests"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

local plugin_config = require("tests.plugin_config")

vim.g.mapleader = " "

require("lazy.minit").setup({
  spec = {
    plugin_config,
    {
      "nvim-telescope/telescope.nvim",
      dependencies = { 'nvim-lua/plenary.nvim' },
      opts = {}
    },
  },
})
