local M = {}

function M.setup(opts)
	local lsputils = require("lsp.utils")

	-- override cmake
	local cmake_opts = lsputils.merge(
		{},
		opts
	)

	-- enable cmake
	require("lspconfig").cmake.setup(cmake_opts)
end

return M
