local auto_scroll = require("claude-code.auto_scroll")
local autocmds = require("claude-code.autocmds")
local buffers = require("claude-code.buffers")
local config = require("claude-code.config")
local state = require("claude-code.state")
local terminal = require("claude-code.terminal")
local windows = require("claude-code.windows")

local M = {}

---@param window_opts_override claude-code.WindowConfig | nil
function M.open(window_opts_override)
  local window_config = window_opts_override or config.window
  windows.setup_windows(window_config, false)
  autocmds.setup(M.close)
end

function M.close()
  terminal.stop_job()
  auto_scroll.cleanup()
  buffers.delete_buffers()

  state:reset()
end

function M.toggle()
  if state.is_open then
    M.hide()
  else
    if state.terminal_job_id then
      M.show()
    else
      M.open()
    end
  end
end

function M.focus()
  if not state.input_winnr or not vim.api.nvim_win_is_valid(state.claude_winnr) then return end

  vim.api.nvim_set_current_win(state.input_winnr)
end

function M.hide() windows.hide_windows() end

function M.show()
  if not state.claude_bufnr or not state.input_bufnr then return end

  windows.setup_windows(config.window, true)
end

return M
