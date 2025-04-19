local completion_utils = require("claude-code.integrations.completion.utils")
local config = require("claude-code.config"):get()

--- @module "blink.cmp"

--- @class blink.cmp.Source
local M = {}

function M.new() return setmetatable({}, { __index = M }) end

function M:enabled() return vim.bo.filetype == "claude-code" end

function M:get_trigger_characters() return { "/", "#" } end

function M:get_completions(ctx, callback)
  local trigger_char = ctx.trigger.character or ctx.line:sub(ctx.bounds.start_col - 1, ctx.bounds.start_col - 1)

  --- @type lsp.Range
  local edit_range = {
    start = {
      line = ctx.bounds.line_number - 1,
      character = ctx.bounds.start_col - 2,
    },
    ["end"] = {
      line = ctx.bounds.line_number - 1,
      character = ctx.bounds.start_col + ctx.bounds.length,
    },
  }

  --- @param items blink.cmp.CompletionItem[]
  local transformed_callback = function(items)
    callback({
      context = ctx,
      is_incomplete_forward = false,
      is_incomplete_backward = false,
      items = items,
    })
  end

  ---@type claude-code.CompletionItem[]
  local prompt_templates = {}
  for cmd, prompt_template in pairs(config.prompt_templates) do
    if not prompt_template then goto continue end
    local command = completion_utils.template_to_completion_item(cmd, prompt_template)
    table.insert(prompt_templates, command)
    ::continue::
  end

  local slash_commands = {}

  for cmd, command_config in pairs(config.slash_commands) do
    if not command_config then goto continue end
    table.insert(slash_commands, {
      type = "claude",
      cmd = cmd,
      desc = command_config.desc,
    })
    ::continue::
  end

  local trigger_char_to_items = {
    ["/"] = slash_commands,
    ["#"] = prompt_templates,
  }

  if not trigger_char_to_items[trigger_char] then
    return function() end
  end

  transformed_callback(vim
    .iter(trigger_char_to_items[trigger_char])
    ---@param cmd claude-code.CompletionItem
    :map(function(cmd)
      --- @type blink.cmp.CompletionItem
      local item = completion_utils.map_completion_item(cmd, edit_range, false)
      item.cursor_column = ctx.bounds.start_col
      return item
    end)
    :totable())
end

function M:execute(ctx, item, callback) completion_utils.execute_completion(item, callback, ctx.bufnr) end

return M
