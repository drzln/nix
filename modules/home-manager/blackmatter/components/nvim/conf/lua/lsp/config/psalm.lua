local M = {}

function M.setup(opts)
	local lsputils = require("lsp.utils")

	-- override psalm
	local psalm_opts = lsputils.merge(
		{},
		opts
	)

	-- enable psalm
	require("lspconfig").psalm.setup(psalm_opts)
end

return M
