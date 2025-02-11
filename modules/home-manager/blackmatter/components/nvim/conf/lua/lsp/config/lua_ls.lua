local M = {}

function M.setup(opts)
	local lsputils = require("lsp.utils")

	-- override lua_ls
	local lua_ls_opts = lsputils.merge(
		{
			settings = {
				Lua = {
					runtime = {
						version = "LuaJIT",
						path = vim.split(package.path, ";", { plain = true }),
					},
					workspace = {
						maxPreload = 100000,
						preloadFileSize = 1000,
						checkThirdParty = false,
						library = {
							[vim.fn.expand('$VIMRUNTIME/lua')] = true,
							[vim.fn.stdpath('config') .. '/lua'] = true,
						},
						ignoreDir = {
							vim.fn.expand('$HOME/.local/share/nvim/site/pack/*/opt/*'),
							vim.fn.expand('$HOME/.local/share/nvim/site/pack/*/start/*'),
						},
					},
					diagnostics = {
						globals = {
							"vim",
							"ngx"
						}
					},
					completion = {
						callSnippet = "Replace"
					},
					telemetry = {
						enable = false,
					},
				}
			}
		},
		opts
	)

	-- enable lua_ls
	require("lspconfig").lua_ls.setup(lua_ls_opts)
end

return M
