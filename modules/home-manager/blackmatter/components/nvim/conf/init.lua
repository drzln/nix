-- Save the original notify function
local orig_notify = vim.notify

-- Override the global notify
vim.notify = function(msg, level, opts)
	if type(msg) == "string" and msg:match("vim.lsp.util.parse_snippet()") and msg:match("deprecated") then
		return
	end
	orig_notify(msg, level, opts)
end

-- Load module loader
local utils = require("utils")

-- Expand ~ and load all includes
-- local lua_home = vim.fn.expand("~/.config/nvim/lua/includes")
-- utils.load_files(lua_home)
require('includes.common').setup
require('includes.treesitter').setup
require('includes.keybindings').setup
require('includes.formatting').setup
require('includes.completion').setup
require('includes.lsp').setup
require('includes.theming').setup
