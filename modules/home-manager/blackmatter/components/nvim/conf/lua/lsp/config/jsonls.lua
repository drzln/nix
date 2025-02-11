local M = {}

function M.setup(opts)
	local lsputils = require("lsp.utils")

	-- override jsonls
	local jsonls_opts = lsputils.merge(
		{},
		opts
	)

	-- enable jsonls
	require("lspconfig").jsonls.setup(jsonls_opts)
end

return M
