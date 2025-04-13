local expect, eq = MiniTest.expect, MiniTest.expect.equality

local T = MiniTest.new_set({
  hooks = {
    pre_case = function()
      -- Reset the config module before each test
      package.loaded["claude-code.config"] = nil
    end,
  },
})

-- Test configuration updates
T["config_update"] = MiniTest.new_set()

T["config_update"]["can_update_simple_values"] = function()
  local config = require("claude-code.config")

  -- Update simple values
  config:set({ cmd = "custom-claude", debug = true })

  -- Check updated values
  local updated = config:get()
  eq(updated.cmd, "custom-claude")
  eq(updated.debug, true)

  -- Check that other values remain unchanged
  eq(updated.window.position, "right")
end

T["config_update"]["can_update_nested_values"] = function()
  local config = require("claude-code.config")

  -- Update nested values
  config:set({
    window = {
      position = "left",
      width = 50,
    },
    keymaps = {
      submit = {
        n = "<Space>",
      },
    },
  })

  local defaults = config:get()

  -- Check updated values
  local updated = config:get()
  eq(updated.window.position, "left")
  eq(updated.window.width, 50)
  eq(updated.keymaps.submit.n, "<Space>")

  -- Check that unspecified nested values remain unchanged
  eq(updated.window.input_height, defaults.window.input_height)
  eq(updated.keymaps.submit.i, defaults.keymaps.submit.i)
end

T["config_update"]["preserves_unspecified_values"] = function()
  local config = require("claude-code.config")
  local defaults = config:get()

  -- Update only one field
  config:set({ cmd = "new-cmd" })

  local updated = config:get()
  -- Check only specified field was updated
  eq(updated.cmd, "new-cmd")

  -- Check all other fields remain the same
  eq(updated.debug, defaults.debug)
  eq(updated.window, defaults.window)
  eq(updated.keymaps, defaults.keymaps)
  eq(updated.experimental, defaults.experimental)
end

return T
