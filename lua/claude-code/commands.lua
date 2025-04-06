local state = require("claude-code.state")
local config = require("claude-code.config"):get()
local auto_scroll = require("claude-code.auto_scroll")

local M = {}

local function setup_terminal_job()
	if config.experimental.hide_input_box then
		local win_cols = vim.api.nvim_win_get_width(state.claude_winnr)
		local node_script = vim.api.nvim_get_runtime_file("node/pty.js", false)[1]
		state.terminal_job_id =
			vim.fn.termopen({ "node", node_script, "--cols", tostring(win_cols), "--cmd", config.cmd })
	else
		state.terminal_job_id = vim.fn.termopen(config.cmd)
	end
end

local function setup_buffers_options()
	-- Set terminal buffer options
	vim.api.nvim_buf_set_option(state.claude_bufnr, "buflisted", false)
	vim.api.nvim_win_call(state.claude_winnr, function()
		vim.cmd("setlocal nonumber norelativenumber")
	end)

	-- Set input buffer options
	vim.api.nvim_buf_set_option(state.input_bufnr, "buftype", "")
	vim.api.nvim_buf_set_option(state.input_bufnr, "swapfile", false)

	-- set file type to "claude-code" to enable syntax highlighting
	vim.api.nvim_buf_set_option(state.input_bufnr, "filetype", "claude-code")
end

local function create_float_windows(window_config, width)
	-- Create floating windows
	-- Claude window (top)
	local claude_buf = vim.api.nvim_create_buf(false, true)
	local win_height = math.floor(vim.o.lines * 0.7)
	local win_width = width
	local row = math.floor((vim.o.lines - win_height - window_config.input_height) / 2)
	local col = math.floor((vim.o.columns - win_width) / 2)

	local claude_opts = {
		style = "minimal",
		relative = "editor",
		width = win_width,
		height = win_height,
		row = row,
		col = col,
		border = "rounded",
	}

	state.claude_winnr = vim.api.nvim_open_win(claude_buf, true, claude_opts)
	state.claude_bufnr = claude_buf

	-- Start terminal job and store job_id in state
	setup_terminal_job()

	-- Input window (bottom)
	local input_buf = vim.api.nvim_create_buf(true, false)
	local input_height = window_config.input_height
	local input_row = row + win_height

	local input_opts = {
		style = "minimal",
		relative = "editor",
		width = win_width,
		height = input_height,
		row = input_row,
		col = col,
		border = "rounded",
	}

	state.input_winnr = vim.api.nvim_open_win(input_buf, true, input_opts)
	state.input_bufnr = input_buf
end

local function create_split_windows(window_config, width)
	-- Create split windows (left or right)
	if window_config.position == "right" then
		vim.cmd("botright vertical new")
	else -- default to left
		vim.cmd("topleft vertical new")
	end
	vim.cmd("vertical resize " .. width)

	-- Create terminal buffer using nvim API
	state.claude_bufnr = vim.api.nvim_get_current_buf()
	state.claude_winnr = vim.api.nvim_get_current_win()

	-- Start terminal job and store job_id in state
	setup_terminal_job()

	-- Create input buffer at the bottom
	vim.cmd("split")
	vim.cmd("resize " .. window_config.input_height)
	state.input_bufnr = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_win_set_buf(0, state.input_bufnr)
	state.input_winnr = vim.api.nvim_get_current_win()
end

---@param window_opts_override claude-code.WindowConfig | nil
function M.open(window_opts_override)
	local window_config = window_opts_override or config.window
	local width_percentage = window_config.width
	local width = math.floor(vim.o.columns * width_percentage / 100)

	-- Create buffers and windows based on position configuration
	if window_config.position == "float" then
		create_float_windows(window_config, width)
	else
		create_split_windows(window_config, width)
	end

	setup_buffers_options()

	local handle_keys = require("claude-code.handle_keys")
	handle_keys.setup_input_bufr_mappings()
	handle_keys.setup_claude_bufr_mappings()

	auto_scroll.setup()

	state.is_open = true
end

function M.close()
	-- Stop the job if it exists using our stored job_id
	if state.terminal_job_id then
		vim.fn.jobstop(state.terminal_job_id)
	end

	-- Close the buffers if they exist
	if state.claude_bufnr and vim.api.nvim_buf_is_valid(state.claude_bufnr) then
		vim.api.nvim_buf_delete(state.claude_bufnr, { force = true })
	end

	if state.input_bufnr and vim.api.nvim_buf_is_valid(state.input_bufnr) then
		vim.api.nvim_buf_delete(state.input_bufnr, { force = true })
	end

	state.reset()
end

function M.toggle()
	if state.is_open == true then
		M.close()
	else
		M.open()
	end
end

function M.focus()
	if not state.input_winnr or not vim.api.nvim_win_is_valid(state.claude_winnr) then
		return
	end

	vim.api.nvim_set_current_win(state.input_winnr)
end

return M
