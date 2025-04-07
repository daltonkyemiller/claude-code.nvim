local windows = require("claude-code.windows")

local M = {}

function M.open(window_opts_override)
	windows.open(window_opts_override)
end

function M.close()
	windows.close()
end

function M.toggle()
	windows.toggle()
end

function M.focus()
	windows.focus()
end

function M.hide()
	windows.hide()
end

function M.show()
	windows.show()
end

return M