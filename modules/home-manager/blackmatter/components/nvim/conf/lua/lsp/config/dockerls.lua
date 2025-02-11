local M = {}

function M.setup(opts)
	local lsputils = require("lsp.utils")

	-- override dockerls
	local dockerls_opts = lsputils.merge(
		{},
		opts
	)

	-- enable dockerls
	require("lspconfig").dockerls.setup(dockerls_opts)
end

return M
