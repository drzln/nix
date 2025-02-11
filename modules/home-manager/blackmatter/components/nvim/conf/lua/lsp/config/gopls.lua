local M = {}

function M.setup(opts)
	local lsputils = require("lsp.utils")

	-- override gopls
	local gopls_opts = lsputils.merge(
		{
			settings = {
				gopls = {
					gofumpt = true
				}
			}
		},
		opts
	)

	-- enable gopls
	require("lspconfig").gopls.setup(gopls_opts)
end

return M
