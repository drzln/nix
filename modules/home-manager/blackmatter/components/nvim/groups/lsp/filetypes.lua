-- modules/home-manager/blackmatter/components/nvim/groups/lsp/filetypes.lua
local M = {}
function M.setup()
	vim.filetype.add({
		pattern = { [".*%.rockspec"] = "lua" },
	})
end
return M
