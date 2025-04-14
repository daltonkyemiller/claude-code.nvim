local state = require("claude-code.state")

--- @module "blink.cmp"

--- @class blink.cmp.Source
local M = {}

function M.new() return setmetatable({}, { __index = M }) end

function M:enabled() return vim.bo.filetype == "claude-code" end

function M:get_trigger_characters() return { "/" } end

--- @class claude-code.blink.slash_command
--- @field cmd string
--- @field desc string

--- @type claude-code.blink.slash_command[]
local slash_commands = {
  {
    cmd = "/clear",
    desc = "Clear conversation history and free up context.",
  },
  {
    cmd = "/compact",
    desc = "Clear conversation history but keep a summary in context. Optional: /compact [instructions for summarization]",
  },
  {
    cmd = "/config",
    desc = "Open config panel",
  },
  {
    cmd = "/cost",
    desc = "Show the total cost and duration of the current session",
  },
  {
    cmd = "/doctor",
    desc = "Checks the health of your Claude Code installation",
  },
  {
    cmd = "/exit",
    desc = "Exit the REPL",
  },
  {
    cmd = "/help",
    desc = "Show help and available commands",
  },
  {
    cmd = "/init",
    desc = "Initialize a new CLAUDE.md file with codebase documentation",
  },
  {
    cmd = "/mcp",
    desc = "Show MCP server connection status",
  },
  {
    cmd = "/memory",
    desc = "Edit Claude memory files",
  },
}

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

  if trigger_char == "/" then
    transformed_callback(vim
      .iter(slash_commands)
      ---@param cmd claude-code.blink.slash_command
      :map(function(cmd)
        --- @type blink.cmp.CompletionItem
        return {
          score_offset = 10,
          source_id = "claude-code",
          source_name = "slash_commands",
          cursor_column = ctx.bounds.start_col,
          kind = vim.lsp.protocol.CompletionItemKind.Function,
          insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
          label = cmd.cmd:sub(2),
          detail = cmd.desc,
          textEdit = {
            newText = cmd.cmd,
            range = edit_range,
          },
          data = {
            type = "slash_command",
          },
        }
      end)
      :totable())
  end

  return function() end
end

function M:execute(ctx, item, callback, default_implementation)
  if type(default_implementation) == "function" then
    vim.lsp.util.apply_text_edits({ { newText = "", range = item.textEdit.range } }, ctx.bufnr, "utf-8")
  end

  if item.data.type == "slash_command" then
    vim.api.nvim_chan_send(state.terminal_job_id, "/" .. item.label)
    vim.schedule(function() vim.api.nvim_chan_send(state.terminal_job_id, "\r") end)

    if item.label == "memory" then vim.api.nvim_input("<Esc>") end
  end

  callback()
end

return M
