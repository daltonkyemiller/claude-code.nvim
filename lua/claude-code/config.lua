---@class claude-code.WindowConfig
---@field position "left" | "right" | "float": Position of windows (default: "left")
---@field width number: Width of windows as percentage of screen width (default: 50)
---@field input_height number: Height of input window in lines (default: 10)

---@class claude-code.Config
---@field cmd string: Command to invoke Claude CLI (default: "claude")
---@field use_default_mappings boolean: Whether to use default mappings (default: true)
---@field hide_cli_input_box boolean: Whether to hide the CLI input box prompt (default: false)
---@field window claude-code.WindowConfig: Window configuration

local M = {}

---@type claude-code.Config
M._defaults = {
	cmd = "claude",
	use_default_mappings = true,
	hide_cli_input_box = true,
	window = {
		position = "float",
		width = 40,
		input_height = 10,
	},
}

---@param user_config claude-code.Config
M.setup = function(user_config)
	M = vim.tbl_deep_extend("force", M._defaults, user_config or {})
end

M = vim.tbl_deep_extend("force", M._defaults, M)

return M
