local M = {}

---@param command claude-code.CompletionItem
---@param trigger_char string
---@param context cmp.Context
---@return lsp.Range
M.get_edit_range = function(command, trigger_char, context)
  local cursor_col = context.cursor.col
  local line = context.cursor_line

  -- Find the last occurrence of trigger_char before cursor
  local closest_pos = -1
  local current_pos = cursor_col

  while current_pos >= 1 do
    local char = line:sub(current_pos, current_pos)
    if char == trigger_char then
      closest_pos = current_pos
      break
    end
    current_pos = current_pos - 1
  end

  return {
    start = {
      line = context.cursor.row - 1,
      character = closest_pos - 1,
    },
    ["end"] = {
      line = context.cursor.row - 1,
      character = closest_pos - 1 + #command.cmd,
    },
  }
end

return M
