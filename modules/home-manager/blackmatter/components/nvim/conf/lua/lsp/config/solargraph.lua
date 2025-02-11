local M = {}


function M.setup(opts)
	local lsputils = require("lsp.utils")

	-- override solargraph
	local solargraph_opts = lsputils.merge(
		{
			settings = {
				solargraph = {
					useBundler = false
				}
			}
		},
		opts
	)

	-- enable solargraph
	require("lspconfig").solargraph.setup(solargraph_opts)
end

return M
