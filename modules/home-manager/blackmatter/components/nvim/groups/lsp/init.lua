-- modules/home-manager/blackmatter/components/nvim/groups/lsp/config.lua
local M = {}

function M.setup()
	require("includes.lsp.settings").apply()
	require("includes.lsp.filetypes").setup()
	require("includes.lsp.mason").setup()
end

return M
