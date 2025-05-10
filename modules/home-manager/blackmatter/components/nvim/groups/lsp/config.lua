-- modules/home-manager/blackmatter/components/nvim/groups/lsp/config.lua
local M = {}

function M.setup()
	require("lsp.settings").apply()
	require("lsp.filetypes").setup()
	require("lsp.mason").setup()
end

return M
