local M = {}

M.is_setup = false

---@param user_config claude-code.ConfigInput
M.setup = function(user_config)
  require("claude-code.config"):set(user_config)

  M.is_setup = true
end

return M
