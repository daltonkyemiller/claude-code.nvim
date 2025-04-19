---@class claude-code.WindowDimensions
---@field width number
---@field height number
---@field row number
---@field col number

local auto_scroll = require("claude-code.auto_scroll")
local buffers = require("claude-code.buffers")
local state = require("claude-code.state")
local terminal = require("claude-code.terminal")

local M = {}

function M.calculate_window_dimensions(window_config)
  local width_percentage = window_config.width
  local width = math.floor(vim.o.columns * width_percentage / 100)
  local win_height = math.floor(vim.o.lines * 0.7)
  local row = math.floor((vim.o.lines - win_height - window_config.input_height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  return {
    width = width,
    height = win_height,
    row = row,
    col = col,
    input_height = window_config.input_height,
    input_row = row + win_height,
  }
end

---@param window_config claude-code.WindowConfig
---@param dimensions claude-code.WindowDimensions
---@param use_existing_buffers boolean
function M.create_float_windows(window_config, dimensions, use_existing_buffers)
  local claude_buf, input_buf

  if use_existing_buffers then
    claude_buf = state.claude_bufnr
    input_buf = state.input_bufnr
  else
    -- Create buffers
    claude_buf = buffers.create_terminal_buffer()
    input_buf = buffers.create_input_buffer()
  end

  -- Claude window (top)
  local claude_opts = {
    style = "minimal",
    relative = "editor",
    width = dimensions.width,
    height = dimensions.height,
    row = dimensions.row,
    col = dimensions.col,
    border = "rounded",
  }

  state.claude_winnr = vim.api.nvim_open_win(claude_buf, true, claude_opts)

  if not use_existing_buffers then
    -- Start terminal job and store job_id in state
    terminal.setup_job(function() require("claude-code.commands").close() end)
  end

  -- Input window (bottom)
  local input_opts = {
    style = "minimal",
    relative = "editor",
    width = dimensions.width,
    height = dimensions.input_height,
    row = dimensions.input_row,
    col = dimensions.col,
    border = "rounded",
  }

  state.input_winnr = vim.api.nvim_open_win(input_buf, true, input_opts)
end

---@param window_config claude-code.WindowConfig
---@param dimensions claude-code.WindowDimensions
---@param use_existing_buffers boolean
function M.create_split_windows(window_config, dimensions, use_existing_buffers)
  -- Create split windows (left or right)
  if window_config.position == "right" then
    vim.cmd("botright vertical new")
  else -- default to left
    vim.cmd("topleft vertical new")
  end
  vim.cmd("vertical resize " .. dimensions.width)

  if use_existing_buffers then
    -- Set Claude buffer
    vim.api.nvim_win_set_buf(0, state.claude_bufnr)
    state.claude_winnr = vim.api.nvim_get_current_win()
  else
    -- Create terminal buffer
    state.claude_winnr = vim.api.nvim_get_current_win()
    buffers.create_terminal_buffer()
    vim.api.nvim_win_set_buf(state.claude_winnr, state.claude_bufnr)

    -- Start terminal job and store job_id in state
    terminal.setup_job(function() require("claude-code.commands").close() end)
  end

  vim.cmd("belowright split")
  vim.cmd("resize " .. window_config.input_height)

  if use_existing_buffers then
    vim.api.nvim_win_set_buf(0, state.input_bufnr)
  else
    buffers.create_input_buffer()
    vim.api.nvim_win_set_buf(0, state.input_bufnr)
  end

  state.input_winnr = vim.api.nvim_get_current_win()
end

---@param window_config claude-code.WindowConfig
---@param use_existing_buffers boolean
function M.setup_windows(window_config, use_existing_buffers)
  local dimensions = M.calculate_window_dimensions(window_config)

  -- Create buffers and windows based on position configuration
  if window_config.position == "float" then
    M.create_float_windows(window_config, dimensions, use_existing_buffers)
  else
    M.create_split_windows(window_config, dimensions, use_existing_buffers)
  end

  if not use_existing_buffers then
    buffers.setup_buffer_options()

    local handle_keys = require("claude-code.handle_keys")
    handle_keys.setup_input_bufr_mappings()
    handle_keys.setup_claude_bufr_mappings()

    auto_scroll.setup()
  end

  state.is_open = true
end

function M.hide_windows()
  if not state.is_open or not state.claude_winnr or not state.input_winnr then return end

  -- Clean up auto-scroll timer when hiding
  auto_scroll.cleanup()

  if vim.api.nvim_win_is_valid(state.claude_winnr) then vim.api.nvim_win_hide(state.claude_winnr) end

  if vim.api.nvim_win_is_valid(state.input_winnr) then vim.api.nvim_win_hide(state.input_winnr) end

  state.is_open = false
end

return M
