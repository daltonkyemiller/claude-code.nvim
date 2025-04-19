local completion_utils = require("claude-code.integrations.completion.utils")
local config = require("claude-code.config"):get()

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

  callback({
    isIncomplete = true,
    items = slash_commands,
  })
end

function SlashCommandsSource:execute(item, callback) completion_utils.execute_completion(item, callback) end

return SlashCommandsSource
