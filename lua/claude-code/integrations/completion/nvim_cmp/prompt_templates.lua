local completion_utils = require("claude-code.integrations.completion.utils")
local config = require("claude-code.config"):get()
local nvim_cmp_utils = require("claude-code.integrations.completion.nvim_cmp.utils")

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

  for cmd, prompt_template in pairs(config.prompt_templates) do
    if not prompt_template then goto continue end
    local command = completion_utils.template_to_completion_item(cmd, prompt_template)
    local edit_range = nvim_cmp_utils.get_edit_range(command, "#", context)
    table.insert(items, completion_utils.map_completion_item(command, edit_range, true))
    ::continue::
  end

  callback({
    isIncomplete = true,
    items = items,
  })
end

function PromptTemplateSource:execute(item, callback) completion_utils.execute_completion(item, callback) end

return PromptTemplateSource
