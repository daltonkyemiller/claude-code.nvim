---@class claude-code.WindowConfig
---@field position "left" | "right" | "float": Position of windows (default: "right")
---@field width number: Width of windows as percentage of screen width (default: 40)
---@field input_height number: Height of input window in lines (default: 10)

---@class claude-code.Config
---@field cmd string: Command to invoke Claude CLI (default: "claude")
---@field use_default_mappings boolean: Whether to use default mappings (default: true)
---@field hide_cli_input_box boolean: Whether to hide the CLI input box prompt (default: false)
---@field window claude-code.WindowConfig: Window configuration

---@class claude-code.WindowConfigInput
---@field position? "left" | "right" | "float": Position of windows (default: "right")
---@field width? number: Width of windows as percentage of screen width (default: 40)
---@field input_height? number: Height of input window in lines (default: 10)

--- @class claude-code.ConfigInput
--- @field cmd string?: Command to invoke Claude CLI (default: "claude")
--- @field use_default_mappings boolean?: Whether to use default mappings (default: true)
--- @field hide_cli_input_box boolean?: Whether to hide the CLI input box prompt (default: false)
--- @field window claude-code.WindowConfigInput?: Window configuration

local Config = {
	---@type claude-code.Config
	config = {
		cmd = "claude",
		use_default_mappings = true,
		hide_cli_input_box = true,
		window = {
			position = "right",
			width = 40,
			input_height = 10,
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
