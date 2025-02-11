local M = {}

function M.setup(opts)
	local lsputils = require("lsp.utils")

	-- override bashls
	local pylsp_opts = lsputils.merge(
		{},
		opts
	)

	-- enable bashls
	require("lspconfig").pylsp.setup(pylsp_opts)
end

return M
