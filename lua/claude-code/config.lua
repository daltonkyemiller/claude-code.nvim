---@class claude-code.Config
---@field cmd string: Command to invoke Claude CLI (default: "claude")
---@field use_default_mappings boolean: Whether to use default mappings (default: true)

local M = {}

---@type claude-code.Config
M._defaults = {
	cmd = "claude",
	use_default_mappings = true,
}

---@param user_config claude-code.Config
M.setup = function(user_config)
	M = vim.tbl_deep_extend("force", M._defaults, user_config or {})
end

M = vim.tbl_deep_extend("force", M._defaults, M)

return M
