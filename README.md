# Claude-Code.nvim

A Neovim plugin that integrates the Claude AI CLI directly into your editor.

## Features

- Interactive Claude AI conversations in a split window
- Multiple window layout options (left, right, floating)
- Customizable window dimensions
- Auto-scrolling for Claude responses
- Custom keyboard shortcuts

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
  use_default_mappings = true, -- Set to false to use your own mappings
  hide_cli_input_box = true, -- Hide the CLI input box prompt
  window = {
    position = "float", -- "left", "right", or "float"
    width = 40, -- Width as percentage of screen width
    input_height = 10 -- Height of input window in lines
  }
})
```

## Usage

Once installed and configured, you can use the following commands:

- `:ClaudeOpen` - Open the Claude window
- `:ClaudeClose` - Close the Claude window
- `:ClaudeToggle` - Toggle the Claude window

### Default Keybindings

When in the input buffer:
- `<C-Enter>` - Send the current buffer content to Claude
- `<Esc>` - Exit input mode

When in the Claude buffer:
- Use normal Neovim terminal navigation

## License

MIT

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.