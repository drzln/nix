local M = {}
function M.setup()
	require("conform").setup({
		formatters_by_ft = {
			lua = { "stylua" },
			nix = { "alejandra" },
			ruby = { "rubocop" },
			json = { "prettier" },
		},
	})
end

return M
