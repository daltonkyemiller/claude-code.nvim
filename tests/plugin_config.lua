---@type LazySpec
return {
  dir = ".",
  event = "VeryLazy",
  opts = {
    -- debug = true,
    window = {
      position = "float",
      width = 40,
    },
    keymaps = {
      arrow_down = {
        i = false,
      },
      arrow_up = {
        i = false,
      },
      arrow_left = {
        i = false,
      },
      arrow_right = {
        i = false,
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
}
