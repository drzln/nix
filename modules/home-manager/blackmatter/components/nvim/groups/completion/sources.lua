-- modules/home-manager/blackmatter/components/nvim/groups/completion/sources.lua
local M = {}

function M.get()
	return {
		{ name = "treesitter" },
		{ name = "nvim_lsp" },
		{ name = "path" },
	}
end

return M
