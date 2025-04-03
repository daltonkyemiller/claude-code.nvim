local M = {}

---@class claude-code.Config
---@field cmd string: Command to invoke Claude CLI (default: "claude")

local default_config = {
	cmd = "claude",
}

local config = default_config

local arrow_keys_ansi = {
	up_arrow = "\x1b[A",
	down_arrow = "\x1b[B",
	right_arrow = "\x1b[C",
	left_arrow = "\x1b[D",
}

M.state = {
	claude_bufnr = nil,
	claude_winnr = nil,
	input_bufnr = nil,
	input_winnr = nil,
	terminal_job_id = nil,
}

---@param user_config claude-code.Config
M.setup = function(user_config)
	config = vim.tbl_deep_extend("force", default_config, user_config or {})
end

-- Opens Claude CLI with an input buffer
M.open = function()
	-- Create a split for the terminal
	vim.cmd("new")

	-- Create terminal buffer using nvim API
	M.state.claude_bufnr = vim.api.nvim_get_current_buf()
	M.state.claude_winnr = vim.api.nvim_get_current_win()

	-- Start terminal job and store job_id in state
	M.state.terminal_job_id = vim.fn.termopen(config.cmd)

	-- Set terminal buffer options
	-- vim.api.nvim_buf_set_option(M.state.claude_bufnr, "buflisted", false)
	vim.cmd("setlocal nonumber norelativenumber")

	-- Create input buffer at the bottom
	vim.cmd("split")
	vim.cmd("resize 10")
	M.state.input_bufnr = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_win_set_buf(0, M.state.input_bufnr)
	M.state.input_winnr = vim.api.nvim_get_current_win()

	-- Set input buffer options
	vim.api.nvim_buf_set_option(M.state.input_bufnr, "buftype", "")
	vim.api.nvim_buf_set_option(M.state.input_bufnr, "swapfile", false)

	-- Set keybinding to send input to Claude
	vim.keymap.set("n", "<CR>", function()
		local lines = vim.api.nvim_buf_get_lines(M.state.input_bufnr, 0, -1, false)
		local input_text = table.concat(lines)

		vim.api.nvim_chan_send(M.state.terminal_job_id, input_text)

		vim.schedule(function()
			vim.api.nvim_chan_send(M.state.terminal_job_id, "\r")
		end)

		-- Clear input buffer
		vim.api.nvim_buf_set_lines(M.state.input_bufnr, 0, -1, false, { "" })
	end, { buffer = M.state.input_bufnr, silent = true })

	vim.keymap.set("n", "h", function()
		vim.api.nvim_chan_send(M.state.terminal_job_id, arrow_keys_ansi.left_arrow)
	end, { buffer = M.state.input_bufnr, silent = true })

	vim.keymap.set("n", "j", function()
		vim.api.nvim_chan_send(M.state.terminal_job_id, arrow_keys_ansi.down_arrow)
	end, { buffer = M.state.input_bufnr, silent = true })

	vim.keymap.set("n", "k", function()
		vim.api.nvim_chan_send(M.state.terminal_job_id, arrow_keys_ansi.up_arrow)
	end, { buffer = M.state.input_bufnr, silent = true })

	vim.keymap.set("n", "l", function()
		vim.api.nvim_chan_send(M.state.terminal_job_id, arrow_keys_ansi.right_arrow)
	end, { buffer = M.state.input_bufnr, silent = true })

	-- Return to the input buffer
	vim.api.nvim_set_current_win(vim.fn.win_getid(vim.fn.winnr()))

	vim.keymap.set("n", "q", function()
		M.close()
	end, { buffer = M.state.input_bufnr, silent = true })

	vim.keymap.set("n", "q", function()
		M.close()
	end, { buffer = M.state.claude_bufnr, silent = true })
end

M.close = function()
	-- Stop the job if it exists using our stored job_id
	if M.state.terminal_job_id then
		vim.fn.jobstop(M.state.terminal_job_id)
	end

	-- Close the buffers if they exist
	if M.state.claude_bufnr and vim.api.nvim_buf_is_valid(M.state.claude_bufnr) then
		vim.api.nvim_buf_delete(M.state.claude_bufnr, { force = true })
	end

	if M.state.input_bufnr and vim.api.nvim_buf_is_valid(M.state.input_bufnr) then
		vim.api.nvim_buf_delete(M.state.input_bufnr, { force = true })
	end

	-- Reset state
	M.state = {
		claude_bufnr = nil,
		claude_winnr = nil,
		input_bufnr = nil,
		terminal_job_id = nil,
	}
end

return M
