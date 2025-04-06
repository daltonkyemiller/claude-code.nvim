--------------------------------------------------------------------------------
---@class claude-code.ExperimentalConfigInput
---@field hide_input_box boolean? Whether to hide claude's input box prompt (default false)
--------------------------------------------------------------------------------
---@class claude-code.ExperimentalConfig
---@field hide_input_box boolean Whether to hide claude's input box prompt (default false)
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
---@class claude-code.WindowConfigInput
---@field position? "left" | "right" | "float" Position of windows (default "right")
---@field width? number Width of windows as percentage of screen width (default 40)
---@field input_height? number Height of input window in lines (default 10)
--------------------------------------------------------------------------------
---@class claude-code.WindowConfig
---@field position "left" | "right" | "float" Position of windows (default "right")
---@field width number Width of windows as percentage of screen width (default 40)
---@field input_height number Height of input window in lines (default 10)
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
---@class claude-code.KeymapItemConfig
---@field n string | "none" Keymap in normal mode
---@field i string | "none" Keymap in insert mode
--------------------------------------------------------------------------------
---@class claude-code.KeymapItemConfigInput
---@field n (string | "none")? Keymap in normal mode
---@field i (string | "none")? Keymap in insert mode
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
---@class claude-code.KeymapConfigInput
---@field submit claude-code.KeymapItemConfigInput? Keymap to submit input in normal mode (default "<C-s>")
---@field escape claude-code.KeymapItemConfigInput?  Keymap to send escape key (default "<Esc>")
---@field switch_window claude-code.KeymapItemConfigInput? Keymap to switch between Claude and input windows (default "<Tab>")
---@field close claude-code.KeymapItemConfigInput?  Keymap to close Claude (default "q")
---@field arrow_up claude-code.KeymapItemConfigInput? Keymap to move up(only when input buffer is empty) in normal mode (default "k" in normal mode, "<C-k>" in insert mode)
---@field arrow_down claude-code.KeymapItemConfigInput? Keymap to move down(only when input buffer is empty) in normal mode (default "j" in normal mode, "<C-j>" in insert mode)
---@field arrow_left claude-code.KeymapItemConfigInput? Keymap to move left(only when input buffer is empty) in normal mode (default "h" in normal mode, "<C-h>" in insert mode)
---@field arrow_right claude-code.KeymapItemConfigInput? Keymap to move right(only when input buffer is empty) in normal mode (default "l" in normal mode, "<C-l>" in insert mode)
--------------------------------------------------------------------------------
---@class claude-code.KeymapConfig
---@field submit claude-code.KeymapItemConfig Keymap to submit input in normal mode (default "<C-s>")
---@field escape claude-code.KeymapItemConfig  Keymap to send escape key (default "<Esc>" in normal mode, "<S-Esc>" in insert mode)
---@field switch_window claude-code.KeymapItemConfig   Keymap to switch between Claude and input windows (default "<Tab>" in normal mode, "<Tab>" in insert mode)
---@field close claude-code.KeymapItemConfig  Keymap to close Claude (default "q" in normal mode, "<C-c>" in insert mode)
---@field arrow_up claude-code.KeymapItemConfig? Keymap to move up(only when input buffer is empty) in normal mode (default "k" in normal mode, "<C-k>" in insert mode)
---@field arrow_down claude-code.KeymapItemConfig? Keymap to move down(only when input buffer is empty) in normal mode (default "j" in normal mode, "<C-j>" in insert mode)
---@field arrow_left claude-code.KeymapItemConfig? Keymap to move left(only when input buffer is empty) in normal mode (default "h" in normal mode, "<C-h>" in insert mode)
---@field arrow_right claude-code.KeymapItemConfig? Keymap to move right(only when input buffer is empty) in normal mode (default "l" in normal mode, "<C-l>" in insert mode)
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
---@class claude-code.ConfigInput
---@field cmd string? Command to invoke Claude CLI (default "claude")
---@field hide_cli_input_box boolean? Whether to hide the CLI input box prompt (default false)
---@field window claude-code.WindowConfigInput? Window configuration
---@field keymaps claude-code.KeymapConfigInput? Keymap configuration
---@field experimental claude-code.ExperimentalConfig? Experimental configuration
---@field debug boolean? Whether to enable debug mode (default false)
--------------------------------------------------------------------------------
---@class claude-code.Config
---@field cmd string Command to invoke Claude CLI (default "claude")
---@field hide_cli_input_box boolean Whether to hide the CLI input box prompt (default false)
---@field window claude-code.WindowConfig Window configuration
---@field keymaps claude-code.KeymapConfig Keymap configuration
---@field experimental claude-code.ExperimentalConfig Experimental configuration
---@field debug boolean Whether to enable debug mode (default false)
--------------------------------------------------------------------------------

local utils = require("claude-code.utils")

local Config = {
	---@type claude-code.Config
	config = {
		debug = false,
		cmd = "claude",
		hide_cli_input_box = true,
		window = {
			position = "right",
			width = 40,
			input_height = 10,
		},
		keymaps = {
			submit = {
				i = "<C-s>",
				n = "<CR>",
			},
			escape = {
				n = "<Esc>",
				i = "none",
			},
			switch_window = {
				n = "<Tab>",
				i = "none",
			},
			close = {
				n = "q",
				i = "<C-c>",
			},
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
			hide_input_box = false,
		},
	},
}

function Config:set(cfg)
	self.config = vim.tbl_deep_extend("force", self.config, cfg)
end

function Config:get()
	return self.config
end

---@export Config
return setmetatable(Config, {
	__index = function(this, k)
		return this.config[k]
	end,
	__newindex = function(this, k, v)
		error("Cannot set config values directly. Use setup() instead.")
	end,
})
