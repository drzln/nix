local M = {}

function M.setup(opts)
	local lsputils = require("lsp.utils")

	-- override pyright
	local pyright_opts = lsputils.merge(
		{},
		opts
	)

	-- enable pyright
	require("lspconfig").pyright.setup(pyright_opts)
end

return M
