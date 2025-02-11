local M = {}

function M.setup(opts)
	local lsputils = require("lsp.utils")

	-- override terraformls
	local terraformls_opts = lsputils.merge(
		{},
		opts
	)

	-- enable terraformls
	require("lspconfig").terraformls.setup(terraformls_opts)
end

return M
