local terminal = require("claude-code.terminal")

--- @module "claude-code.integrations.completion.utils"

local M = {}

--- Handle applying text and executing commands after completion
--- @param item table The completion item
--- @param callback function Callback to run after completion
--- @param bufnr? number Optional buffer number
--- @param default_implementation? function Optional default implementation function
function M.execute_completion(item, callback, bufnr, default_implementation)
  --- @param new_text string
  local function handle_apply(new_text)
    if type(default_implementation) == "function" or new_text ~= "" then
      vim.lsp.util.apply_text_edits(
        { { newText = new_text, range = item.textEdit.range } },
        bufnr or vim.api.nvim_get_current_buf(),
        "utf-8"
      )

      -- Calculate cursor position for multi-line text
      local lines = vim.split(new_text, "\n", { plain = true })
      local last_line = lines[#lines]
      local end_line = item.textEdit.range.start.line + #lines - 1
      local end_col = #lines == 1 and item.textEdit.range.start.character + #new_text or #last_line

      vim.api.nvim_win_set_cursor(0, { end_line + 1, end_col })
    end

    if item.data.type == "claude" then
      local cmd = item.label
      if cmd:sub(1, 1) ~= "/" then cmd = "/" .. cmd end
      terminal.send_input(cmd)
      terminal.send_enter()

      if item.label:match("memory$") then vim.api.nvim_input("<Esc>") end
    end

    callback()
  end

  if item.data.callback then
    item.data.callback(handle_apply)
  else
    handle_apply("")
  end
end

return M
