local state = require("claude-code.state")

local M = {}

function M.create_terminal_buffer()
  local buf = vim.api.nvim_create_buf(false, true)
  state.claude_bufnr = buf
  return buf
end

function M.create_input_buffer()
  local buf = vim.api.nvim_create_buf(true, false)
  state.input_bufnr = buf
  return buf
end

function M.setup_terminal_buffer_options()
  if not state.claude_bufnr then
    return false
  end
  
  -- Set terminal buffer options
  vim.api.nvim_buf_set_option(state.claude_bufnr, "buflisted", false)
  vim.api.nvim_buf_set_option(state.claude_bufnr, "swapfile", false)
  
  if state.claude_winnr and vim.api.nvim_win_is_valid(state.claude_winnr) then
    vim.api.nvim_win_call(state.claude_winnr, function() 
      vim.cmd("setlocal nonumber norelativenumber") 
    end)
  end
  
  return true
end

function M.setup_input_buffer_options()
  if not state.input_bufnr then
    return false
  end
  
  -- Set input buffer options
  vim.api.nvim_buf_set_option(state.input_bufnr, "buflisted", false)
  vim.api.nvim_buf_set_option(state.input_bufnr, "buftype", "nofile")
  vim.api.nvim_buf_set_option(state.input_bufnr, "swapfile", false)
  vim.api.nvim_buf_set_option(state.input_bufnr, "filetype", "claude-code")
  
  return true
end

function M.setup_buffer_options()
  M.setup_terminal_buffer_options()
  M.setup_input_buffer_options()
end

function M.delete_terminal_buffer()
  if state.claude_bufnr and vim.api.nvim_buf_is_valid(state.claude_bufnr) then
    vim.api.nvim_buf_delete(state.claude_bufnr, { force = true })
    state.claude_bufnr = nil
    return true
  end
  return false
end

function M.delete_input_buffer()
  if state.input_bufnr and vim.api.nvim_buf_is_valid(state.input_bufnr) then
    vim.api.nvim_buf_delete(state.input_bufnr, { force = true })
    state.input_bufnr = nil
    return true
  end
  return false
end

function M.clear_input_buffer()
  if state.input_bufnr and vim.api.nvim_buf_is_valid(state.input_bufnr) then
    vim.api.nvim_buf_set_lines(state.input_bufnr, 0, -1, false, { "" })
    return true
  end
  return false
end

function M.get_input_buffer_text()
  if state.input_bufnr and vim.api.nvim_buf_is_valid(state.input_bufnr) then
    local lines = vim.api.nvim_buf_get_lines(state.input_bufnr, 0, -1, false)
    return table.concat(lines, "\n")
  end
  return ""
end

function M.delete_buffers()
  M.delete_terminal_buffer()
  M.delete_input_buffer()
end

return M