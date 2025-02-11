local M = {}

function M.setup(opts)
	local lsputils = require("lsp.utils")

	-- override eslint
	local eslint_opts = lsputils.merge(
		{},
		opts
	)

	-- enable eslint
	require("lspconfig").eslint.setup(eslint_opts)
end

return M
