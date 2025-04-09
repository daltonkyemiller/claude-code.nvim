local state = require("claude-code.state")
local config = require("claude-code.config"):get()
local auto_scroll = require("claude-code.auto_scroll")

local M = {}

local function setup_terminal_job()
	local term_args = {
		on_exit = function()
			M.close()
		end,
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

		if config.debug then
			table.insert(script_args, "--debug")
		end

		state.terminal_job_id = vim.fn.termopen(script_args, term_args)
	else
		state.terminal_job_id = vim.fn.termopen(config.cmd, term_args)
	end

	-- Stop the job when leaving Vim
	-- vim.api.nvim_create_autocmd("VimLeavePre", {
	-- 	callback = function()
	-- 		P(state.terminal_job_id)
	-- 		P("stopping terminal job")
	-- 		if state.terminal_job_id then
	-- 			vim.fn.jobstop(state.terminal_job_id)
	-- 		end
	-- 	end,
	-- })
end

local function setup_buffers_options()
	-- Set terminal buffer options
	vim.api.nvim_buf_set_option(state.claude_bufnr, "buflisted", false)
	vim.api.nvim_buf_set_option(state.claude_bufnr, "swapfile", false)
	vim.api.nvim_win_call(state.claude_winnr, function()
		vim.cmd("setlocal nonumber norelativenumber")
	end)

	-- Set input buffer options
	vim.api.nvim_buf_set_option(state.input_bufnr, "buftype", "nofile")
	vim.api.nvim_buf_set_option(state.input_bufnr, "buflisted", false)
	vim.api.nvim_buf_set_option(state.input_bufnr, "swapfile", false)

	-- set file type to "claude-code" to enable syntax highlighting
	vim.api.nvim_buf_set_option(state.input_bufnr, "filetype", "claude-code")
end

local function calculate_window_dimensions(window_config)
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

local function create_float_windows(window_config, dimensions, use_existing_buffers)
	local claude_buf, input_buf

	if use_existing_buffers then
		claude_buf = state.claude_bufnr
		input_buf = state.input_bufnr
	else
		-- Create buffers
		claude_buf = vim.api.nvim_create_buf(false, true)
		input_buf = vim.api.nvim_create_buf(true, false)
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
		state.claude_bufnr = claude_buf
		-- Start terminal job and store job_id in state
		setup_terminal_job()
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

	if not use_existing_buffers then
		state.input_bufnr = input_buf
	end
end

local function create_split_windows(window_config, dimensions, use_existing_buffers)
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
		-- Create terminal buffer using nvim API
		state.claude_bufnr = vim.api.nvim_get_current_buf()
		state.claude_winnr = vim.api.nvim_get_current_win()

		-- Start terminal job and store job_id in state
		setup_terminal_job()
	end

	-- Create input window
	vim.cmd("split")
	vim.cmd("resize " .. window_config.input_height)

	if use_existing_buffers then
		vim.api.nvim_win_set_buf(0, state.input_bufnr)
	else
		state.input_bufnr = vim.api.nvim_create_buf(true, false)
		vim.api.nvim_win_set_buf(0, state.input_bufnr)
	end

	state.input_winnr = vim.api.nvim_get_current_win()
end

local function setup_windows(window_config, use_existing_buffers)
	local dimensions = calculate_window_dimensions(window_config)

	-- Create buffers and windows based on position configuration
	if window_config.position == "float" then
		create_float_windows(window_config, dimensions, use_existing_buffers)
	else
		create_split_windows(window_config, dimensions, use_existing_buffers)
	end

	if not use_existing_buffers then
		setup_buffers_options()

		local handle_keys = require("claude-code.handle_keys")
		handle_keys.setup_input_bufr_mappings()
		handle_keys.setup_claude_bufr_mappings()

		auto_scroll.setup()
	end

	state.is_open = true
end

---@param window_opts_override claude-code.WindowConfig | nil
function M.open(window_opts_override)
	local window_config = window_opts_override or config.window
	setup_windows(window_config, false)
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
	if not state.input_winnr or not vim.api.nvim_win_is_valid(state.claude_winnr) then
		return
	end

	vim.api.nvim_set_current_win(state.input_winnr)
end

function M.hide()
	if not state.is_open or not state.claude_winnr or not state.input_winnr then
		return
	end

	if vim.api.nvim_win_is_valid(state.claude_winnr) then
		vim.api.nvim_win_hide(state.claude_winnr)
	end

	if vim.api.nvim_win_is_valid(state.input_winnr) then
		vim.api.nvim_win_hide(state.input_winnr)
	end

	state.is_open = false
end

function M.show()
	if not state.claude_bufnr or not state.input_bufnr then
		return
	end

	setup_windows(config.window, true)
end

return M
