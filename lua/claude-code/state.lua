---@class claude-code.State
---@field claude_bufnr number | nil
---@field claude_winnr number	| nil
---@field input_bufnr number | nil
---@field input_winnr number | nil
---@field terminal_job_id number | nil
---@field is_open boolean

local defaults = {
	claude_bufnr = nil,
	claude_winnr = nil,
	input_bufnr = nil,
	input_winnr = nil,
	terminal_job_id = nil,
	is_open = false,
}

---@class claude-code.State
local M = {
	_defaults = defaults,
}

M.reset = function()
	---@class claude-code.State
	for k, v in pairs(defaults) do
		M[k] = v
	end
end

M.reset()

return M
