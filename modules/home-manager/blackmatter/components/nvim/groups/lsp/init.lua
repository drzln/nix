-- modules/home-manager/blackmatter/components/nvim/groups/lsp/config.lua
local M = {}
function M.setup()
	require("groups.lsp.settings").apply()
	require("groups.lsp.filetypes").setup()
	require("groups.lsp.mason").setup()
end
return M
