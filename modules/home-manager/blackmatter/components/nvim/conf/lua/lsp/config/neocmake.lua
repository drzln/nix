local M = {}

function M.setup(opts)
	local lsputils = require("lsp.utils")

	-- override neocmake
	local neocmake_opts = lsputils.merge(
		{},
		opts
	)

	-- enable neocmake
	require("lspconfig").neocmake.setup(neocmake_opts)
end

return M
