local M = {}
function M.setup()
	require("conform").setup({
		formatters_by_ft = {
			["terraform-vars"] = { "terraform_fmt" },
			terraform = { "terraform_fmt" },
			typescript = { "prettier" },
			javascript = { "prettier" },
			markdown = { "prettier" },
			tf = { "terraform_fmt" },
			json = { "prettier" },
			nix = { "alejandra" },
			html = { "prettier" },
			ruby = { "rubocop" },
			python = { "black" },
			rust = { "rustfmt" },
			lua = { "stylua" },
			toml = { "taplo" },
			zsh = { "shfmt" },
			sh = { "shfmt" },
		},
	})
end

return M
