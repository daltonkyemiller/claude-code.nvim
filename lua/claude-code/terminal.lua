local state = require("claude-code.state")
local config = require("claude-code.config"):get()

local M = {}

function M.setup_job(on_exit_callback)
  local term_args = {
    on_exit = on_exit_callback,
  }

  if config.experimental.hide_input_box then
    local win_cols = vim.api.nvim_win_get_width(state.claude_winnr)
    local win_rows = vim.api.nvim_win_get_height(state.claude_winnr)
    local node_script = vim.api.nvim_get_runtime_file("node/pty.js", false)[1]
    local script_args = {
      "node",
      node_script,
      "--cols",
      tostring(win_cols),
      "--rows",
      tostring(win_rows),
      "--cmd",
      config.cmd,
    }

    if config.debug then table.insert(script_args, "--debug") end

    state.terminal_job_id = vim.fn.termopen(script_args, term_args)
  else
    state.terminal_job_id = vim.fn.termopen(config.cmd, term_args)
  end
  
  return state.terminal_job_id
end

function M.stop_job()
  if state.terminal_job_id then 
    vim.fn.jobstop(state.terminal_job_id)
    state.terminal_job_id = nil
    return true
  end
  return false
end

function M.send_input(input_text)
  if not state.terminal_job_id then
    return false
  end
  
  vim.api.nvim_chan_send(state.terminal_job_id, input_text)
  return true
end

function M.send_enter()
  if not state.terminal_job_id then
    return false
  end
  
  vim.schedule(function()
    vim.api.nvim_chan_send(state.terminal_job_id, "\r")
  end)
  return true
end

function M.send_escape()
  if not state.terminal_job_id then
    return false
  end
  
  local escKey = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
  vim.api.nvim_chan_send(state.terminal_job_id, escKey)
  return true
end

function M.send_sequence(sequence)
  if not state.terminal_job_id then
    return false
  end
  
  vim.api.nvim_chan_send(state.terminal_job_id, sequence)
  return true
end

return M
