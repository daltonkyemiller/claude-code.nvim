local expect, eq = MiniTest.expect, MiniTest.expect.equality

local T = MiniTest.new_set()

T["no error when calling setup"] = function()
	expect.no_error(function()
		require("claude-code").setup({})
	end)
end

T["is_setup to be true after setup"] = function()
	local claude = require("claude-code")
	eq(claude.is_setup, true)
end

return T
