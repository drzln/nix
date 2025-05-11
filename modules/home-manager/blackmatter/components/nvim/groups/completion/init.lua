-- modules/home-manager/blackmatter/components/nvim/groups/completion/init.lua
local M = {}

function M.setup()
	local cmp = require("cmp")
	local mappings = require("groups.completion.mappings")
	local sources = require("groups.completion.sources")
	local config = require("groups.completion.config")

	vim.cmd([[ set completeopt=menu,menuone,noselect ]])

	cmp.setup({
		mapping = mappings.get(),
		sources = cmp.config.sources(sources.get()),
	})

	config.setup_avante() -- Optional, uncomment when ready
end

return M
