local completion_utils = require("claude-code.integrations.completion.utils")
local nvim_cmp_utils = require("claude-code.integrations.completion.nvim_cmp.utils")
local slash_commands = require("claude-code.integrations.completion.slash_commands")

---@class SlashCommandsSource : cmp.Source
local SlashCommandsSource = {}
SlashCommandsSource.__index = SlashCommandsSource

function SlashCommandsSource:is_available() return vim.bo.filetype == "claude-code" end

function SlashCommandsSource:get_trigger_characters() return { "/" } end

function SlashCommandsSource:get_keyword_pattern() return [[\%(\/\)\k*]] end

function SlashCommandsSource:complete(param, callback)
  --- @type cmp.Context
  local context = param.context

  local items = {}


  for _, command in ipairs(slash_commands) do
    local edit_range = nvim_cmp_utils.get_edit_range(command, "/", context)
    table.insert(items, completion_utils.map_completion_item(command, edit_range, true))
  end

  callback({
    isIncomplete = true,
    items = items,
  })
end

function SlashCommandsSource:execute(item, callback) completion_utils.execute_completion(item, callback) end

return SlashCommandsSource
