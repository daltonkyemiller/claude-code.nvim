local state = require("claude-code.state")
local config = require("claude-code.config")
local auto_scroll = require("claude-code.auto_scroll")

local M = {}

-- Opens Claude CLI with an input buffer
M.open = function()
	-- Create a split for the terminal
	vim.cmd("new")

	-- Create terminal buffer using nvim API
	state.claude_bufnr = vim.api.nvim_get_current_buf()
	state.claude_winnr = vim.api.nvim_get_current_win()

	-- Start terminal job and store job_id in state
	state.terminal_job_id = vim.fn.termopen(config.cmd)

	-- Set terminal buffer options
	vim.api.nvim_buf_set_option(state.claude_bufnr, "buflisted", false)
	vim.cmd("setlocal nonumber norelativenumber")

	-- Create input buffer at the bottom
	vim.cmd("split")
	vim.cmd("resize 10")
	state.input_bufnr = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_win_set_buf(0, state.input_bufnr)
	state.input_winnr = vim.api.nvim_get_current_win()

	-- Set input buffer options
	vim.api.nvim_buf_set_option(state.input_bufnr, "buftype", "")
	vim.api.nvim_buf_set_option(state.input_bufnr, "swapfile", false)

	-- set file type to "claude-code" to enable syntax highlighting
	vim.api.nvim_buf_set_option(state.input_bufnr, "filetype", "claude-code")

	if config.use_default_mappings then
		local handle_keys = require("claude-code.handle_keys")
		handle_keys.setup_input_bufr_mappings()
		handle_keys.setup_claude_bufr_mappings()
	end

	auto_scroll.setup()

	state.is_open = true
end

M.close = function()
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

M.toggle = function()
	if state.is_open == true then
		M.close()
	else
		M.open()
	end
end

return M
