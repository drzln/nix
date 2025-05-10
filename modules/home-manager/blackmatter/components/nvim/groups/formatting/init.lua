local M = {}
function M.setup()
	require("conform").setup({
		formatters_by_ft = {
			zig = { "zig fmt" },
			["terraform-vars"] = { "terraform_fmt" },
			java = { "google-java-format" },
			swift = { "swift_format" },
			php = { "php_cs_fixer" },
			terraform = { "terraform_fmt" },
			typescript = { "prettier" },
			javascript = { "prettier" },
			markdown = { "prettier" },
			tf = { "terraform_fmt" },
			yaml = { "prettier" },
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
