local M = {}

function M.setup(opts)
	local lsputils = require("lsp.utils")

	-- override yamlls
	local yamlls_opts = lsputils.merge(
		{},
		opts
	)

	-- enable yamlls
	require("lspconfig").yamlls.setup(yamlls_opts)
end

return M
