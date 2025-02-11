local M = {}

function M.setup(opts)
	local lsputils = require("lsp.utils")

	-- override jdtls
	local jdtls_opts = lsputils.merge(
		{},
		opts
	)

	-- enable jdtls
	require("lspconfig").jdtls.setup(jdtls_opts)
end

return M
