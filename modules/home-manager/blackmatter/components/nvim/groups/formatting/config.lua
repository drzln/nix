local M = {}
function M.setup()
	require("conform").setup({
		formatters_by_ft = {
			typescript = { "prettier" },
			javascript = { "prettier" },
			json = { "prettier" },
			nix = { "alejandra" },
			html = { "prettier" },
			ruby = { "rubocop" },
			python = { "black" },
			rust = { "rustfmt" },
			lua = { "stylua" },
			toml = { "taplo" },
		},
	})
end

return M
