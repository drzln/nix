-- modules/home-manager/blackmatter/components/nvim/groups/lsp/settings.lua
local M = {}

function M.apply()
	vim.diagnostic.config({
		virtual_text = true,
		signs = true,
		update_in_insert = false,
		severity_sort = true,
	})
end

return M
