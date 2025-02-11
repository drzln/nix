local M = {}

function M.setup(opts)
	local lsputils = require("lsp.utils")

	-- override bashls
	local bashls_opts = lsputils.merge(
		{},
		opts
	)

	-- enable bashls
	require("lspconfig").bashls.setup(bashls_opts)
end

return M
