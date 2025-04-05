local state = require("claude-code.state"):get()
local cmds = require("claude-code.commands")

local M = {}

local arrow_keys_ansi = {
	h = "\x1b[D",
	j = "\x1b[B",
	k = "\x1b[A",
	l = "\x1b[C",
}

local function buf_lacks_content(bufnr)
	local first_char = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
	return first_char == ""
end

local function update_movement_mappings()
	if buf_lacks_content(state.input_bufnr) then
		for key, ansi_code in pairs(arrow_keys_ansi) do
			vim.keymap.set("n", key, function()
				vim.api.nvim_chan_send(state.terminal_job_id, ansi_code)
			end, { buffer = state.input_bufnr, silent = true })
		end
	else
		for key in pairs(arrow_keys_ansi) do
			pcall(vim.keymap.del, "n", key, { buffer = state.input_bufnr })
		end
	end
end

M.setup_input_bufr_mappings = function()
	-- Set keybinding to send input to Claude
	vim.keymap.set("n", "<CR>", function()
		local lines = vim.api.nvim_buf_get_lines(state.input_bufnr, 0, -1, false)
		local input_text = table.concat(lines, "\n")

		vim.api.nvim_chan_send(state.terminal_job_id, input_text)

		vim.schedule(function()
			vim.api.nvim_chan_send(state.terminal_job_id, "\r")
		end)

		-- Clear input buffer
		vim.api.nvim_buf_set_lines(state.input_bufnr, 0, -1, false, { "" })
	end, { buffer = state.input_bufnr, silent = true })

	vim.keymap.set("n", "<Esc>", function()
		local escKey = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
		vim.api.nvim_chan_send(state.terminal_job_id, escKey)
	end, { buffer = state.input_bufnr, silent = true })

	vim.keymap.set("n", "<Tab>", function()
		vim.api.nvim_set_current_win(state.claude_winnr)
	end, { buffer = state.input_bufnr, silent = true })

	-- Set up autocmd to update mappings when buffer content changes
	vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
		buffer = state.input_bufnr,
		callback = update_movement_mappings,
	})

	-- Initial setup of mappings
	update_movement_mappings()

	vim.keymap.set("n", "q", function()
		cmds.close()
	end, { buffer = state.input_bufnr, silent = true })
end

M.setup_claude_bufr_mappings = function()
	vim.keymap.set("n", "<Tab>", function()
		vim.api.nvim_set_current_win(state.input_winnr)
	end, { buffer = state.claude_bufnr, silent = true })

	vim.keymap.set("n", "q", function()
		cmds.close()
	end, { buffer = state.claude_bufnr, silent = true })
end

return M
