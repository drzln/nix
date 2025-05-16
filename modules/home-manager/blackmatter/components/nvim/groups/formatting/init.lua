local M = {}
function M.setup()
	require("conform").setup({
		formatters = {
			zigfmt = {
				command = "zig",
				args = { "fmt", "--stdin" },
				stdin = true,
			},
			gofmt = {
				command = "gofmt",
				args = { "-s" },
				stdin = true,
			},
		},
		formatters_by_ft = {
			["terraform-vars"] = { "terraform_fmt" },
			typescript = { "prettier" },
			javascript = { "prettier" },
			terraform = { "terraform_fmt" },
			markdown = { "prettier" },
			python = { "black" },
			swift = { "swift_format" },
			java = { "google-java-format" },
			yaml = { "prettier" },
			json = { "prettier" },
			html = { "prettier" },
			ruby = { "rubocop" },
			rust = { "rustfmt" },
			toml = { "taplo" },
			zig = { "zigfmt" },
			php = { "php_cs_fixer" },
			nix = { "alejandra" },
			lua = { "stylua" },
			zsh = { "shfmt" },
			tf = { "terraform_fmt" },
			sh = { "shfmt" },
			go = { "gofmt" },
		},
	})
end
return M
