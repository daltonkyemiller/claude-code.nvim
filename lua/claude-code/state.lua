---@class claude-code.State
---@field claude_bufnr number | nil
---@field claude_winnr number	| nil
---@field input_bufnr number | nil
---@field input_winnr number | nil
---@field terminal_job_id number | nil
---@field is_open boolean

local DEFAULTS = {
	claude_bufnr = nil,
	claude_winnr = nil,
	input_bufnr = nil,
	input_winnr = nil,
	terminal_job_id = nil,
	is_open = false,
}

local state = vim.deepcopy(DEFAULTS)

local M = {}

function M.reset()
	for k, _ in pairs(state) do
		state[k] = DEFAULTS[k]
	end
end

setmetatable(M, {
	__index = function(_, key)
		return state[key]
	end,
	__newindex = function(_, key, value)
		state[key] = value
	end,
})

return M
