local M = {}

function M.setup(opts)
	local lsputils = require("lsp.utils")

	local hyprls_opts = lsputils.merge(
		{},
		opts
	)

	require("lspconfig").hyprls.setup(hyprls_opts)
end

return M
