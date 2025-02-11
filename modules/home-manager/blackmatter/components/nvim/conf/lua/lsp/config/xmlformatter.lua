local M = {}

function M.setup(opts)
	local lsputils = require("lsp.utils")

	-- override xmlformatter
	local xmlformatter_opts = lsputils.merge(
		{},
		opts
	)

	-- enable xmlformatter
	require("lspconfig").xmlformatter.setup(xmlformatter_opts)
end

return M
