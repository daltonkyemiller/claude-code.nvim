local completion_utils = require("claude-code.integrations.completion.utils")
local nvim_cmp_utils = require("claude-code.integrations.completion.nvim_cmp.utils")
local prompt_templates = require("claude-code.integrations.completion.prompt_templates")

---@class PromptTemplateSource : cmp.Source
local PromptTemplateSource = {}
PromptTemplateSource.__index = PromptTemplateSource

function PromptTemplateSource:is_available() return vim.bo.filetype == "claude-code" end

function PromptTemplateSource:get_trigger_characters() return { "#" } end

function PromptTemplateSource:get_keyword_pattern() return [[#\k*]] end

function PromptTemplateSource:complete(param, callback)
  --- @type cmp.Context
  local context = param.context

  local items = {}

  for _, command in ipairs(prompt_templates) do
    local edit_range = nvim_cmp_utils.get_edit_range(command, "#", context)
    table.insert(items, completion_utils.map_completion_item(command, edit_range, true))
  end

  callback({
    isIncomplete = true,
    items = items,
  })
end

function PromptTemplateSource:execute(item, callback) completion_utils.execute_completion(item, callback) end

return PromptTemplateSource
