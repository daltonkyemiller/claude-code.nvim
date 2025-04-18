--- @type claude-code.ClaudeCompletionItem[]
local claude_slash_commands = {
  {
    type = "claude",
    cmd = "/clear",
    desc = "Clear conversation history and free up context.",
  },
  {
    type = "claude",
    cmd = "/compact",
    desc = "Clear conversation history but keep a summary in context. Optional: /compact [instructions for summarization]",
  },
  {
    type = "claude",
    cmd = "/config",
    desc = "Open config panel",
  },
  {
    type = "claude",
    cmd = "/cost",
    desc = "Show the total cost and duration of the current session",
  },
  {
    type = "claude",
    cmd = "/doctor",
    desc = "Checks the health of your Claude Code installation",
  },
  {
    type = "claude",
    cmd = "/exit",
    desc = "Exit the REPL",
  },
  {
    type = "claude",
    cmd = "/help",
    desc = "Show help and available commands",
  },
  {
    type = "claude",
    cmd = "/init",
    desc = "Initialize a new CLAUDE.md file with codebase documentation",
  },
  {
    type = "claude",
    cmd = "/mcp",
    desc = "Show MCP server connection status",
  },
  {
    type = "claude",
    cmd = "/memory",
    desc = "Edit Claude memory files",
  },
  {
    type = "claude",
    cmd = "/migrate-installer",
    desc = "Migrate from global npm installation to local installation",
  },
  {
    type = "claude",
    cmd = "/pr-comments",
    desc = "Get comments from a GitHub pull request",
  },
  {
    type = "claude",
    cmd = "/release-notes",
    desc = "View release notes",
  },
  {
    type = "claude",
    cmd = "/bug",
    desc = "Submit feedback about Claude Code",
  },
  {
    type = "claude",
    cmd = "/review",
    desc = "Review a pull request",
  },
  {
    type = "claude",
    cmd = "/theme",
    desc = "Change the theme (light/dark)",
  },
  {
    type = "claude",
    cmd = "/vim",
    desc = "Toggle between Vim and Normal editing modes",
  },
  {
    type = "claude",
    cmd = "/allowed-tools",
    desc = "List all currently allowed tools",
  },
  {
    type = "claude",
    cmd = "/logout",
    desc = "Sign out from your Anthropic account",
  },
  {
    type = "claude",
    cmd = "/login",
    desc = "Switch Anthropic accounts",
  },
}

---@type claude-code.CompletionItem[]
local M = {}

vim.list_extend(M, claude_slash_commands)

return M
