local config = require("claude-code.config")
local state = require("claude-code.state")

local M = {}

---@param on_pick fun(paths: string[]): nil
M.pick = function(on_pick)
  local snacks_picker_ok, snacks_picker = pcall(require, "snacks.picker")

  if snacks_picker_ok and (config.picker_provider == "snacks" or config.picker_provider == "detect") then
    snacks_picker.files({
      on_close = function() vim.api.nvim_set_current_win(state.input_winnr) end,
      confirm = function(picker, item, action)
        ---@param paths string[]
        local pick_cb = function(paths)
          on_pick(paths)
          picker:close()
        end

        local items = picker:selected()
        if #items == 0 then
          local current = picker:current()
          if not current then return pick_cb({}) end

          return pick_cb({ current.file })
        end

        local paths = {}
        for _, item in ipairs(items) do
          table.insert(paths, item.file)
        end

        return pick_cb(paths)
      end,
    })
    return
  end

  local telescope_ok, telescope_builtin = pcall(require, "telescope.builtin")

  if telescope_ok and (config.picker_provider == "telescope" or config.picker_provider == "detect") then
    local actions = require("telescope.actions")
    local actions_state = require("telescope.actions.state")

    telescope_builtin.find_files({
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          local picker = actions_state.get_current_picker(prompt_bufnr)
          local multi_selection = picker:get_multi_selection()
          local selection = actions_state.get_selected_entry()
          local selections = selection and { selection[1] } or {}

          for _, item in ipairs(multi_selection) do
            table.insert(selections, item[1])
          end

          on_pick(selections)
        end)

        return true
      end,
    })

    return
  end

  vim.notify("[Claude Code]: No supported picker provider found.", vim.log.levels.WARN)
end

return M
