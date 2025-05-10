-- modules/home-manager/blackmatter/components/nvim/groups/lsp/mason.lua
local mason_lspconfig = require("mason-lspconfig")
local servers = require("lsp.servers")
local lspconfig = require("lspconfig")
local utils = require("lsp.utils")
local mason = require("mason")
local M = {}
function M.setup()
	mason.setup()
	local mason_servers = mason_lspconfig.get_available_servers()
	local manual_servers = { "ts_ls", "nixd" }
	local available_servers = vim.list_extend(vim.deepcopy(mason_servers), manual_servers)
	local to_install = vim.tbl_filter(function(server)
		return not utils.is_excluded(server) and not utils.is_configure_only(server)
	end, available_servers)
	mason_lspconfig.setup({ ensure_installed = to_install, automatic_installation = false })
	for _, server in ipairs(available_servers) do
		if not utils.is_excluded(server) then
			local ok, err = pcall(function()
				lspconfig[server].setup(servers.get(server))
			end)
			if not ok then
				vim.notify("Error setting up " .. server .. ": " .. err, vim.log.levels.ERROR)
			end
		end
	end
end
return M
