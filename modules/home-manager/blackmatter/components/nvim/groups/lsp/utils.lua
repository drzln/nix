-- modules/home-manager/blackmatter/components/nvim/groups/lsp/utils.lua
local M = {}
M.exclude_servers = require("includes.lsp.exclude_list")
M.configure_only = {
	"rust_analyzer",
	"ruby_lsp",
	"ts_ls",
	"nixd",
}
function M.is_excluded(server)
	return vim.tbl_contains(M.exclude_servers, server)
end
function M.is_configure_only(server)
	return vim.tbl_contains(M.configure_only, server)
end
function M.merge_configs(base, overrides)
	return vim.tbl_deep_extend("force", {}, base, overrides)
end
return M
