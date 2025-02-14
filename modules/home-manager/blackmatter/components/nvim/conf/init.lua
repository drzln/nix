-- Save the original notify function
local orig_notify = vim.notify

-- Override the global notify
vim.notify = function(msg, level, opts)
	-- If it's specifically the parse_snippet() deprecation, ignore it
	if type(msg) == "string" and msg:match("vim.lsp.util.parse_snippet()") and msg:match("deprecated") then
		return
	end

	-- Otherwise, call original notify
	orig_notify(msg, level, opts)
end

local utils = require("utils")
local lua_home = "~/.config/nvim/lua"
utils.load_files(lua_home .. "/includes")
