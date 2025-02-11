local M = {}

function M.setup(opts)
	local lsputils = require("lsp.utils")

	-- override ts_ls
	local ts_ls_opts = lsputils.merge(
		{},
		opts
	)

	-- enable bashls
	require("lspconfig").ts_ls.setup(ts_ls_opts)
end

return M
