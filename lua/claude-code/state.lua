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

local State = {
	---@type claude-code.State
	state = vim.deepcopy(DEFAULTS),
}

function State:get()
	return self.state
end

function State:reset()
	self.state = vim.deepcopy(DEFAULTS)
end

---@export State
return setmetatable(State, {
	__index = function(this, key)
		return this.state[key]
	end,
	__newindex = function(this, key, value)
		this.state[key] = value
	end,
})
