---@class claude-code.State
---@field claude_bufnr number | nil
---@field claude_winnr number	| nil
---@field input_bufnr number | nil
---@field input_winnr number | nil
---@field last_visited_bufnr number | nil
---@field last_visited_winnr number | nil
---@field terminal_job_id number | nil
---@field is_open boolean

local defaults = {
  claude_bufnr = nil,
  claude_winnr = nil,
  input_bufnr = nil,
  input_winnr = nil,
  last_visited_bufnr = vim.api.nvim_get_current_buf(),
  last_visited_winnr = vim.api.nvim_get_current_win(),
  terminal_job_id = nil,
  is_open = false,
}

local state = vim.deepcopy(defaults)

---@class claude-code.StateModule : claude-code.State
local M = {}

function M:reset() state = vim.deepcopy(defaults) end

setmetatable(M, {
  __index = function(this, k) return state[k] end,
  __newindex = function(this, k, v) state[k] = v end,
})

return M
