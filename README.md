# Claude-Code.nvim

> **⚠️ WORK IN PROGRESS**: This plugin is under active development. APIs and functionality will change significantly

A Neovim plugin that integrates the Claude AI CLI directly into your editor.

![Claude-Code.nvim](assets/claude_code_nvim.png)

## Features

- Interactive Claude AI conversations in a split window
- Multiple window layout options (left, right, floating)
- Customizable window dimensions
- Auto-scrolling for Claude responses
- Custom keyboard shortcuts with separate normal/insert mode mappings
- Window hide/show functionality to temporarily clear Claude from view
- Arrow key navigation when input buffer is empty
- Experimental feature to hide Claude's input box (using a separate node process and second PTY)
- Integration with blink.lua

## Requirements

- Neovim 0.7.0 or later
- Node.js installed on your system
- [Claude CLI](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview) installed and configured

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "daltonkyemiller/claude-code.nvim",
  -- NOTE: only required if using experimental.hide_input_box feature
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
use({
	"daltonkyemiller/claude-code.nvim",
	-- NOTE: only required if using experimental.hide_input_box feature
	run = "cd node && npm install",
	config = function()
		require("claude-code").setup({
			-- your configuration here
		})
	end,
})
```

## Configuration

Below is the full configuration with all available options:

```lua
require("claude-code").setup({
	cmd = "claude", -- Command to invoke Claude CLI
	use_default_mappings = true, -- Set to false to disable automatic key mappings
	debug = false, -- Enable debug logging
	window = {
		position = "float", -- "left", "right", or "float"
		width = 40, -- Width as percentage of screen width
		input_height = 10, -- Height of input window in lines
	},
	keymaps = {
		submit = {
			n = "<CR>",
			i = "<C-s>",
		},
		escape = {
			n = "<Esc>",
			i = "<Esc>",
		},
		switch_window = {
			n = "<Tab>",
			i = "<Tab>",
		},
		close = {
			n = "q",
			i = "q",
		},
		-- Arrow key navigation (only active when input buffer is empty)
		arrow_up = {
			n = "k",
			i = "<C-k>",
		},
		arrow_down = {
			n = "j",
			i = "<C-j>",
		},
		arrow_left = {
			n = "h",
			i = "<C-h>",
		},
		arrow_right = {
			n = "l",
			i = "<C-l>",
		},
	},
	experimental = {
		hide_input_box = false, -- Hide Claude's input box prompt (uses a separate node process and a second PTY)
	},
})
```

## Usage

### Commands

The plugin exposes several Lua functions that can be used in your own mappings or commands:

```lua
-- Start Claude
require("claude-code").open()

-- Hide Claude windows (preserves state)
require("claude-code").hide()

-- Show Claude windows (restores from hidden state)
require("claude-code").show()

-- Toggle between hidden and shown states (will start Claude if necessary)
require("claude-code").toggle()

-- Focus the input window
require("claude-code").focus()
```

You can create commands for these functions:

```lua
vim.api.nvim_create_user_command("Claude", function()
	require("claude-code").open()
end, {})
vim.api.nvim_create_user_command("ClaudeHide", function()
	require("claude-code").hide()
end, {})
vim.api.nvim_create_user_command("ClaudeShow", function()
	require("claude-code").show()
end, {})
vim.api.nvim_create_user_command("ClaudeToggle", function()
	require("claude-code").toggle()
end, {})
```

### Default Keybindings

When in the input buffer:

- `<CR>` (Enter) - Send the current buffer content to Claude
- `<C-s>` - Send the current buffer content to Claude (insert mode)
- `<Esc>` - Send escape key to Claude (normal mode)
- `<Tab>` - Switch to Claude buffer (normal mode)
- `q` - Close Claude (normal mode)
- `hjkl` - Navigate the input buffer (normal mode)

When in the Claude buffer:

- `<Tab>` - Switch to input buffer
- `q` - Close Claude

You can customize these keybindings by modifying the `keymaps` table in your configuration.

## License

MIT

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.
