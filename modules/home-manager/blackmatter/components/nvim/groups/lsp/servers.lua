-- modules/home-manager/blackmatter/components/nvim/groups/lsp/servers.lua
local common = {
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
}
local M = {}
M.configs = {
	lua_ls = {
		settings = {
			Lua = { diagnostics = { globals = { "vim" } } },
		},
	},
	nixd = {
		on_attach = function(_, _)
			vim.lsp.handlers["textDocument/didSave"] = function(...) end
		end,
		settings = {
			nixd = {
				options = {
					nixpkgs = {
						expr = "import <nixpkgs> {}",
					},
				},
			},
		},
	},
}
function M.get(server)
	local config = M.configs[server] or {}
	return vim.tbl_deep_extend("force", {}, common, config)
end
return M
