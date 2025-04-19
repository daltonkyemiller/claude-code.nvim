local state = require("claude-code.state")

local M = {}

local function create_augroup()
  local group = vim.api.nvim_create_augroup("ClaudeCode", { clear = true })

  return group
end

---@param on_close fun(): nil
function M.setup(on_close)
  local group = create_augroup()

  -- Autocmd for cleanup on exit
  vim.api.nvim_create_autocmd({ "VimLeavePre", "QuitPre" }, {
    group = group,
    callback = on_close,
  })

  vim.api.nvim_create_autocmd({ "BufEnter" }, {
    group = group,
    callback = function(args)
      if args.buf == state.input_bufnr or args.buf == state.claude_bufnr then return end

      state.last_visited_bufnr = args.buf
    end,
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
