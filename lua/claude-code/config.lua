---@class claude-code.PromptTemplate
---@field desc string
---@field on_execute fun(replace_text: (fun(text: string): nil), state: claude-code.State): nil

---@class claude-code.Config
local defaults = {
  debug = false,
  cmd = "claude",
  hide_cli_input_box = true,
  window = {
    position = "right",
    width = 40,
    input_height = 10,
  },
  keymaps = {
    submit = {
      i = "<C-s>",
      n = "<CR>",
    },
    escape = {
      n = "<Esc>",
      i = "none",
    },
    switch_window = {
      n = "<Tab>",
      i = "none",
    },
    close = {
      n = "q",
      i = "<C-c>",
    },
    arrow_up = {
      n = "k",
      i = "<C-k>",
    },
    arrow_down = {
      n = "j",
      i = "<C-j>",
    },
    arrow_left = {
      n = "h",
      i = "<C-h>",
    },
    arrow_right = {
      n = "l",
      i = "<C-l>",
    },
  },
  ---@type table<string, claude-code.PromptTemplate>
  prompt_templates = {
    ["#buffer"] = {
      desc = "Paste path of an open buffer",
      on_execute = function(replace_text, state)
        if state.last_visited_bufnr == nil or vim.api.nvim_buf_is_valid(state.last_visited_bufnr) == false then
          vim.notify("No last visited buffer", vim.log.levels.ERROR)
          return replace_text("")
        end

        local file_name = vim.api.nvim_buf_get_name(state.last_visited_bufnr)
        local relative_to_cwd = vim.fn.fnamemodify(file_name, ":.")
        replace_text(relative_to_cwd)
      end,
    },
    ["#diagnostics"] = {
      desc = "Paste diagnostics from an open buffer",
      on_execute = function(replace_text, state)
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
                "%s %s:%s:%s: %s",
                vim.diagnostic.severity[diagnostic.severity],
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
  },
  experimental = {
    hide_input_box = false,
  },
}

local config = vim.deepcopy(defaults)

---@class claude-code.ConfigModule : claude-code.Config
local M = {}

---@param cfg claude-code.Config
function M:set(cfg) config = vim.tbl_deep_extend("force", config, cfg) end

function M:get() return config end

setmetatable(M, {
  __index = function(this, k) return config[k] end,
  __newindex = function(this, k, v) error("Cannot set config values directly. Use setup() instead.") end,
})

return M
