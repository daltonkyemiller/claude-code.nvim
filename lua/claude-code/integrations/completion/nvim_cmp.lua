local completion_utils = require("claude-code.integrations.completion.utils")
local prompt_templates = require("claude-code.integrations.completion.prompt_templates")
local slash_commands = require("claude-code.integrations.completion.slash_commands")

---@class Source : cmp.Source
local Source = {}
Source.__index = Source

function Source:is_available() return vim.bo.filetype == "claude-code" end

function Source:get_trigger_characters() return { "/", "#" } end

function Source:get_keyword_pattern() return [[\%(@\|#\|/\)\k*]] end

function Source:complete(params, callback)
  local items = {}

  local all_commands = {}
  vim.list_extend(all_commands, slash_commands)
  vim.list_extend(all_commands, prompt_templates)

  for _, command in ipairs(all_commands) do
    local edit_range = {
      start = {
        line = params.context.cursor.row - 1,
        character = params.context.cursor.col - 2,
      },
      ["end"] = {
        line = params.context.cursor.row - 1,
        character = params.context.cursor.col + #command.cmd,
      },
    }

    table.insert(items, {
      label = command.cmd,
      insertText = command.cmd,
      kind = vim.lsp.protocol.CompletionItemKind.Function,
      documentation = command.desc,
      textEdit = {
        newText = command.cmd,
        range = edit_range,
      },
      data = {
        type = command.type,
        callback = command.type == "custom" and command.on_execute or nil,
      },
    })
  end

  callback({
    isIncomplete = false,
    items = items,
  })
end

function Source:execute(item, callback) completion_utils.execute_completion(item, callback) end

return Source
