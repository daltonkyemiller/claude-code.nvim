# Claude-Code.nvim

> **⚠️ WORK IN PROGRESS**: This plugin is under active development. APIs and functionality will change significantly

A Neovim plugin that integrates the Claude AI CLI directly into your editor.

## Features

- Interactive Claude AI conversations in a split window
- Multiple window layout options (left, right, floating)
- Customizable window dimensions
- Auto-scrolling for Claude responses
- Custom keyboard shortcuts
- Experimental feature to hide Claude's input box (using a separate node process and second PTY)

## Requirements

- Neovim 0.7.0 or later
- Node.js installed on your system
- [Claude CLI](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview) installed and configured

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "daltonkyemiller/claude-code.nvim",
  build = "cd node && npm install",
  config = function()
    require("claude-code").setup({
      -- your configuration here
    })
  end
}
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  "daltonkyemiller/claude-code.nvim",
  run = "cd node && npm install",
  config = function()
    require("claude-code").setup({
      -- your configuration here
    })
  end
}
```

## Configuration

```lua
require("claude-code").setup({
  cmd = "claude", -- Command to invoke Claude CLI
  use_default_mappings = true, -- Set to false to disable automatic key mappings
  hide_cli_input_box = true, -- Hide the CLI input box prompt
  window = {
    position = "float", -- "left", "right", or "float"
    width = 40, -- Width as percentage of screen width
    input_height = 10 -- Height of input window in lines
  },
  keymaps = {
    submit = "<C-s>", -- Keymap to submit input in normal mode
    escape = "<Esc>", -- Keymap to send escape key
    switch_window = "<Tab>", -- Keymap to switch between Claude and input windows
    close = "q" -- Keymap to close Claude
  },
  experimental = {
    hide_input_box = false, -- Hide Claude's input box prompt (uses a separate node process and a second PTY)
  }
})
```

## Usage

TODO 

### Default Keybindings

When in the input buffer:
- `<CR>` (Enter) - Send the current buffer content to Claude (for backward compatibility)
- `<C-s>` - Send the current buffer content to Claude
- `<Esc>` - Send escape key to Claude
- `<Tab>` - Switch to Claude buffer
- `q` - Close Claude

When in the Claude buffer:
- `<Tab>` - Switch to input buffer
- `q` - Close Claude
- Use normal Neovim terminal navigation

You can customize these keybindings by modifying the `keymaps` table in your configuration.

## License

MIT

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.
