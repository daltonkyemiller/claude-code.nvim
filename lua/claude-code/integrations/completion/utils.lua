local state = require("claude-code.state")
local terminal = require("claude-code.terminal")

--- @module "claude-code.integrations.completion.utils"

local M = {}

-- Convert PromptTemplate to CustomCompletionItem
---@param cmd string
---@param template claude-code.PromptTemplate
---@return claude-code.CustomCompletionItem
function M.template_to_completion_item(cmd, template)
  return {
    type = "custom",
    cmd = cmd,
    desc = template.desc,
    on_execute = template.on_execute,
  }
end

--- Creates a completion item from a command
--- @param cmd claude-code.CompletionItem The completion command/item
--- @param range table LSP range for the text edit
--- @param keep_prefix boolean Whether to keep the prefix (default: false)
--- @param source_name? string The source name (default: "slash_commands")
--- @return blink.cmp.CompletionItem
function M.map_completion_item(cmd, range, keep_prefix, source_name)
  return {
    source_id = "claude-code",
    score_offset = 5,
    label = keep_prefix and cmd.cmd or cmd.cmd:sub(2),
    detail = cmd.desc,
    -- documentation = cmd.desc,
    kind = vim.lsp.protocol.CompletionItemKind.Function,
    insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
    textEdit = {
      newText = cmd.cmd,
      range = range,
    },
    data = {
      type = cmd.type,
      callback = cmd.type == "custom" and cmd.on_execute or nil,
    },
  }
end

--- Handle applying text and executing commands after completion
--- @param item table The completion item
--- @param callback function Callback to run after completion
--- @param bufnr? number Optional buffer number
function M.execute_completion(item, callback, bufnr)
  --- @param new_text string
  local function handle_apply(new_text)
    vim.lsp.util.apply_text_edits(
      { { newText = new_text, range = item.textEdit.range } },
      bufnr ~= nil and bufnr or vim.api.nvim_get_current_buf(),
      "utf-8"
    )

    -- Calculate cursor position for multi-line text
    local lines = vim.split(new_text, "\n", { plain = true })
    local last_line = lines[#lines]
    local end_line = item.textEdit.range.start.line + #lines - 1
    local end_col = #lines == 1 and item.textEdit.range.start.character + #new_text or #last_line

    vim.api.nvim_win_set_cursor(0, { end_line + 1, end_col })

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
    item.data.callback(handle_apply, state)
  else
    handle_apply("")
  end
end

return M
