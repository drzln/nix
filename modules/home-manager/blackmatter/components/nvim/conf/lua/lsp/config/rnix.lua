local M = {}

function M.setup(opts)
	local lsputils = require("lsp.utils")

	-- override rnix-lsp
	local rnix_lsp_opts = lsputils.merge(
		{},
		opts
	)

	-- enable rnix-lsp
	require("lspconfig").rnix.setup(rnix_lsp_opts)
end

return M
