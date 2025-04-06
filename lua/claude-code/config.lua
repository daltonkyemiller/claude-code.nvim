---@class claude-code.WindowConfig
---@field position "left" | "right" | "float": Position of windows (default: "right")
---@field width number: Width of windows as percentage of screen width (default: 40)
---@field input_height number: Height of input window in lines (default: 10)

---@class claude-code.KeymapConfig
---@field submit string: Keymap to submit input in normal mode (default: "<C-s>")
---@field escape string: Keymap to send escape key (default: "<Esc>")
---@field switch_window string: Keymap to switch between Claude and input windows (default: "<Tab>")
---@field close string: Keymap to close Claude (default: "q")

---@class claude-code.ExperimentalConfigInput
---@field hide_input_box boolean?: Whether to hide claude's input box prompt (default: false)

---@class claude-code.ExperimentalConfig
---@field hide_input_box boolean: Whether to hide claude's input box prompt (default: false)

---@class claude-code.Config
---@field cmd string: Command to invoke Claude CLI (default: "claude")
---@field hide_cli_input_box boolean: Whether to hide the CLI input box prompt (default: false)
---@field window claude-code.WindowConfig: Window configuration
---@field keymaps claude-code.KeymapConfig: Keymap configuration
---@field experimental claude-code.ExperimentalConfig: Experimental configuration

---@class claude-code.WindowConfigInput
---@field position? "left" | "right" | "float": Position of windows (default: "right")
---@field width? number: Width of windows as percentage of screen width (default: 40)
---@field input_height? number: Height of input window in lines (default: 10)

---@class claude-code.KeymapConfigInput
---@field submit? string: Keymap to submit input in normal mode (default: "<C-s>")
---@field escape? string: Keymap to send escape key (default: "<Esc>")
---@field switch_window? string: Keymap to switch between Claude and input windows (default: "<Tab>")
---@field close? string: Keymap to close Claude (default: "q")

--- @class claude-code.ConfigInput
--- @field cmd string?: Command to invoke Claude CLI (default: "claude")
--- @field hide_cli_input_box boolean?: Whether to hide the CLI input box prompt (default: false)
--- @field window claude-code.WindowConfigInput?: Window configuration
--- @field keymaps claude-code.KeymapConfigInput?: Keymap configuration
--- @field experimental claude-code.ExperimentalConfig?: Experimental configuration

local Config = {
	---@type claude-code.Config
	config = {
		cmd = "claude",
		hide_cli_input_box = true,
		window = {
			position = "right",
			width = 40,
			input_height = 10,
		},
		keymaps = {
			submit = "<C-s>",
			escape = "<Esc>",
			switch_window = "<Tab>",
			close = "q",
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
