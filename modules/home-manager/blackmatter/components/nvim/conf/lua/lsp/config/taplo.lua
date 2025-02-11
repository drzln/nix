local M = {}

function M.setup(opts)
	local lspconfig = require("lspconfig")

	-- Override taplo
	local taplo_opts = vim.tbl_extend("force", {}, opts)

	-- Enable taplo
	lspconfig.taplo.setup(taplo_opts)
end

return M
