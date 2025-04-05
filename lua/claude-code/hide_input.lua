local config = require("claude-code.config"):get()
local state = require("claude-code.state"):get()

local M = {}

-- Function to hide CLI input box
M.hide_cli_input_box = function()
	if not config.hide_cli_input_box or not state.claude_bufnr then
		return
	end

	if vim.api.nvim_buf_is_valid(state.claude_bufnr) then
		local lines = vim.api.nvim_buf_get_lines(state.claude_bufnr, 0, -1, false)
		local start_line = -1
		local end_line = -1

		-- Find the CLI input box by looking for ╭ followed by a line with >
		for i = 1, #lines - 1 do
			if lines[i]:find("╭") and lines[i + 1]:find(">") then
				start_line = i
				-- Find the end of the box (line starting with ╰)
				for j = i + 2, #lines do
					if lines[j]:match("^╰") then
						end_line = j
						break
					end
				end
				break
			end
		end

		-- Clear any existing extmarks first
		local ns_id = vim.api.nvim_create_namespace("claude_code_hide_input")
		vim.api.nvim_buf_clear_namespace(state.claude_bufnr, ns_id, 0, -1)

		-- Delete the input box if found
		if start_line > 0 and end_line > 0 then
			-- Only attempt to modify if buffer is modifiable
			if vim.api.nvim_buf_get_option(state.claude_bufnr, "modifiable") then
				vim.api.nvim_buf_set_lines(state.claude_bufnr, start_line - 1, end_line, false, {})
			else
				vim.print("Buffer is not modifiable")
				-- For non-modifiable buffers (like terminals), hide visually using extmarks
				local ns_id = vim.api.nvim_create_namespace("claude_code_hide_input")
				for i = start_line - 1, end_line do
					local line_len = #(vim.api.nvim_buf_get_lines(state.claude_bufnr, i, i + 1, false)[1] or "")
					local spaces = string.rep(" ", line_len)
					vim.api.nvim_buf_set_extmark(state.claude_bufnr, ns_id, i, 0, {
						virt_text = { { spaces, "Normal" } },
						virt_text_pos = "overlay",
						hl_mode = "replace",
					})
				end
			end
		end
	end
end

return M
