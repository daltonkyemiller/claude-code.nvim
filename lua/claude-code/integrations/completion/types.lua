--- @class claude-code.ClaudeCompletionItem
--- @field type "claude"
--- @field cmd string
--- @field desc string

--- @class claude-code.CustomCompletionItem
--- @field type "custom"
--- @field cmd string
--- @field desc string
--- @field on_execute fun(replace_text: fun(str: string): nil): nil

--- @alias claude-code.CompletionItem
--- | claude-code.ClaudeCompletionItem
--- | claude-code.CustomCompletionItem
