local M = {}

function M.setup(opts)
	local lsputils = require("lsp.utils")

	-- override clangd
	local clangd_opts = lsputils.merge(
		{},
		opts
	)

	-- enable clangd
	require("lspconfig").clangd.setup(clangd_opts)
end

return M
