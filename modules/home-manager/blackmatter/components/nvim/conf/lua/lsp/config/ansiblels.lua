local M = {}

function M.setup(opts)
	local lsputils = require("lsp.utils")

	-- override ansiblels
	local ansiblels_opts = lsputils.merge(
		{},
		opts
	)

	-- enable _ansiblels
	require("lspconfig").ansiblels.setup(ansiblels_opts)
end

return M
