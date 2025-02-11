local M = {}

function M.setup(opts)
	local lspconfig = require("lspconfig")

	-- local rust_analyzer_path = vim.fn.trim(vim.fn.system("nix eval --raw nixpkgs.rust-analyzer.outPath")) ..
	-- 		"/bin/rust-analyzer"
	--
	-- if rust_analyzer_path == "" then
	-- 	error("rust-analyzer not found in Nix environment")
	-- 	return
	-- end

	local rust_analyzer_opts = vim.tbl_extend("force", {
		settings = {
			["rust-analyzer"] = {
				assist = {
					importMergeBehavior = "last",
					importPrefix = "by_self",
				},
				cargo = {
					loadOutDirsFromCheck = true
				},
				procMacro = {
					enable = true
				},
				formatting = {
					rustfmt = {
						enableRangeFormatting = true,
						extraArgs = {},
					}
				},
			}
		},
	}, opts)

	lspconfig.rust_analyzer.setup(rust_analyzer_opts)
end

return M
