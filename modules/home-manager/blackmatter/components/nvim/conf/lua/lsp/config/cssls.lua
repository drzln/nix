local M = {}

function M.setup(opts)
	local lsputils = require("lsp.utils")

	-- override bashls
	local cssls_opts = lsputils.merge(
		{
			cmd = { "css-languageserver", "--stdio" },
		},
		opts
	)

	-- enable bashls
	require("lspconfig").cssls.setup(cssls_opts)
end

return M
