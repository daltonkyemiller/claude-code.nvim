local M = {}

M.is_setup = false

---@param user_config claude-code.Config
M.setup = function(user_config)
  require("claude-code.config"):set(user_config)

  local is_cmp, cmp = pcall(require, "cmp")

  if is_cmp then
    cmp.register_source("claude_code_commands", require("claude-code.integrations.completion.nvim_cmp.slash_commands"))
    cmp.register_source(
      "claude_code_prompt_templates",
      require("claude-code.integrations.completion.nvim_cmp.prompt_templates")
    )

    cmp.setup.filetype({ "claude-code" }, {
      sources = {
        { name = "claude_code_commands" },
        { name = "claude_code_prompt_templates" },
      },
    })
  end

  M.is_setup = true
end

return M
