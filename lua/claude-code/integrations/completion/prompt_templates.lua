local state = require("claude-code.state")

--- @type claude-code.CustomCompletionItem[]
local M = {
  {
    type = "custom",
    cmd = "#buffer",
    desc = "Paste path of an open buffer",
    on_execute = function(replace_text)
      if state.last_visited_bufnr == nil or vim.api.nvim_buf_is_valid(state.last_visited_bufnr) == false then
        vim.notify("No last visited buffer", vim.log.levels.ERROR)
        return replace_text("")
      end

      local file_name = vim.api.nvim_buf_get_name(state.last_visited_bufnr)
      local relative_to_cwd = vim.fn.fnamemodify(file_name, ":.")
      replace_text(relative_to_cwd)
    end,
  },
  {
    type = "custom",
    cmd = "#diagnostics",
    desc = "Paste diagnostics from an open buffer",
    on_execute = function(replace_text)
      if state.last_visited_bufnr == nil or vim.api.nvim_buf_is_valid(state.last_visited_bufnr) == false then
        vim.notify("No last visited buffer", vim.log.levels.ERROR)
        return replace_text("")
      end

      local diagnostics = vim.diagnostic.get(state.last_visited_bufnr)

      if #diagnostics == 0 then
        vim.notify("No diagnostics found", vim.log.levels.WARN)
        return replace_text("")
      end

      local file_name = vim.api.nvim_buf_get_name(state.last_visited_bufnr)
      local relative_to_cwd = vim.fn.fnamemodify(file_name, ":.")

      local diagnostics_strs = vim
        .iter(diagnostics)
        :map(
          function(diagnostic)
            return string.format(
              "%s:%s:%s: %s",
              diagnostic.lnum,
              diagnostic.col,
              diagnostic.severity,
              diagnostic.message
            )
          end
        )
        :totable()

      local diagnostics_str = table.concat(diagnostics_strs, "\n")

      local prompt_template = [[
The following diagnostics were found in ]] .. relative_to_cwd .. [[:

%s

Can you help me fix them?
]]

      replace_text(string.format(prompt_template, diagnostics_str))
    end,
  },
}

return M
