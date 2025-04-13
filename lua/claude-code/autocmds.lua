local commands = require("claude-code.commands")

local M = {}

local function create_augroup()
  local group = vim.api.nvim_create_augroup("ClaudeCode", { clear = true })

  return group
end

function M.setup()
  local group = create_augroup()

  -- Autocmd for cleanup on exit
  vim.api.nvim_create_autocmd({ "VimLeavePre", "QuitPre" }, {
    group = group,
    callback = function() commands.close() end,
  })
end

function M.setup_input_buffer_text_changed(bufnr, current_normal_mappings, current_insert_mappings, update_callback)
  local group = vim.api.nvim_create_augroup("ClaudeCodeInputBuffer", { clear = true })

  -- Autocmd for updating mappings when buffer content changes
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = group,
    buffer = bufnr,
    callback = function() update_callback(current_normal_mappings, current_insert_mappings) end,
  })
end

return M