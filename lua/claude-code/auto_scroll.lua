local state = require("claude-code.state")

local M = {}

-- Store the timer globally to allow proper cleanup
M.timer = nil

-- Stop and clean up any existing timer
M.cleanup = function()
  if not M.timer then return end

  M.timer:stop()
  M.timer:close()
  M.timer = nil
end

M.setup = function()
  -- Clean up any existing timer first
  M.cleanup()

  if not state.claude_bufnr or not state.claude_winnr then return end

  M.timer = vim.uv.new_timer()
  if not M.timer then return end

  M.timer:start(
    0,
    100,
    vim.schedule_wrap(function()
      if
        state.claude_bufnr
        and state.claude_winnr
        and vim.api.nvim_buf_is_valid(state.claude_bufnr)
        and vim.api.nvim_win_is_valid(state.claude_winnr)
      then
        -- Only scroll if the Claude buffer is NOT focused
        local current_win = vim.api.nvim_get_current_win()
        if current_win ~= state.claude_winnr then
          -- If the user hasn't scrolled up, force scroll
          local total_lines = vim.api.nvim_buf_line_count(state.claude_bufnr)
          local cursor_line = vim.api.nvim_win_get_cursor(state.claude_winnr)[1]
          local height = vim.api.nvim_win_get_height(state.claude_winnr)

          local at_bottom = (cursor_line + height) >= total_lines
          if at_bottom then vim.api.nvim_win_set_cursor(state.claude_winnr, { total_lines, 0 }) end
        end
      else
        M.cleanup()
      end
    end)
  )
end

return M
