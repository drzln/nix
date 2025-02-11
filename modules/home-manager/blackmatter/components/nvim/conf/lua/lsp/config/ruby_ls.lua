local M = {}

function M.setup(opts)
	local lsputils = require("lsp.utils")

	-- override ruby_ls
	local ruby_ls_opts = lsputils.merge(
		{},
		opts
	)

	-- enable ruby_ls
	require("lspconfig").ruby_ls.setup(ruby_ls_opts)
end

return M
