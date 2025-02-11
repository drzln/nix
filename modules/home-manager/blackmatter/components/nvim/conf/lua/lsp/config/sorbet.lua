local M = {}

function M.setup(opts)
	local lsputils = require("lsp.utils")

	-- override sorbet
	local sorbet_opts = lsputils.merge(
		{},
		opts
	)

	-- enable sorbet
	require("lspconfig").sorbet.setup(sorbet_opts)
end

return M
