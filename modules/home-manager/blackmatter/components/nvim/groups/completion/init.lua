-- modules/home-manager/blackmatter/components/nvim/groups/completion/init.lua
local M = {}

function M.setup()
	local cmp = require("cmp")
	local mappings = require("completion.mappings")
	local sources = require("completion.sources")
	local config = require("completion.config")

	vim.cmd([[ set completeopt=menu,menuone,noselect ]])

	cmp.setup({
		mapping = mappings.get(),
		sources = cmp.config.sources(sources.get()),
	})

	config.setup_avante() -- Optional, uncomment when ready
end

return M
