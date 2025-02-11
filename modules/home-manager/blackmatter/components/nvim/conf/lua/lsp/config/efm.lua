local M = {}

function M.setup(opts)
	local lsputils = require("lsp.utils")

	-- override bashls
	local efm_opts = lsputils.merge(
		{
			flags = {
				debounce_text_changes = 150,
			},
			init_options = { documentFormatting = true },
			filetypes = { "python" },
			settings = {
				rootMarkers = { ".git/" },
				languages = {
					python = {
						{ formatCommand = "black --quiet -", formatStdin = true }
					}
				}
			}
		},
		opts
	)

	-- enable bashls
	require("lspconfig").efm.setup(efm_opts)
end

return M
