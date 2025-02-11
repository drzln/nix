local M = {}

local function setup_lsp()
	local cfg = require("lsp.config")

	-- grab your own lsp utilities/overrides
	local lsputils = require("lsp.utils")

	-- generic configuration for every language server
	local opts = { on_attach = lsputils.lsp_attach }

	-- configure language servers
	for _, lang in ipairs(cfg.enabled_languages) do
		require("lsp.config." .. lang .. "").setup(opts)
	end
end

function M.setup()
	setup_lsp()
end

return M
