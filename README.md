# claude-code.nvim

A Neovim plugin for interacting with the Claude CLI.

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "daltonkyemiller/claude-code.nvim",
  config = function()
    require("claude-code").setup({
      -- Optional configuration
      cmd = "claude", -- Command to invoke Claude CLI
      hide_cli_input_box = true, -- Hide the Claude CLI input box prompt
      window = {
        position = "float", -- "float", "left", or "right"
        width = 40, -- Width as percentage of screen
        input_height = 10, -- Height of input window in lines
      },
    })
  end,
}
```

## Usage

### Open Claude Interface

```lua
:lua require("claude-code").open()
```

This will:
1. Open a split window with Claude CLI in the top section
2. Open an input buffer in the bottom section
3. Set up keybindings for interaction

### Close Claude Interface

```lua
:lua require("claude-code").close()
```

This will:
1. Stop the Claude CLI process
2. Close both the terminal and input buffers
3. Reset the plugin state

### Key Bindings

In the input buffer:
- `<Enter>` (normal mode): Sends the contents of the input buffer to the Claude CLI and clears the input buffer

## Requirements

- Neovim 0.7.0+
- Claude CLI installed and available in your path