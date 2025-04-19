
--- @class claude-code.CompletionItemBase
--- @field cmd string
--- @field desc string

--- @class claude-code.ClaudeCompletionItem : claude-code.CompletionItemBase
--- @field type "claude"

--- @class claude-code.SlashCommand
--- @field desc string

--- @class claude-code.PromptTemplate
--- @field desc string
--- @field on_execute fun(replace_text: fun(text: string): nil, state: claude-code.State): nil

--- @class claude-code.CustomCompletionItem : claude-code.CompletionItemBase
--- @field type "custom"
--- @field on_execute fun(replace_text: fun(text: string): nil, state: claude-code.State): nil

--- @alias claude-code.CompletionItem
--- | claude-code.ClaudeCompletionItem
--- | claude-code.CustomCompletionItem
