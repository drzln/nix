local M = {}

function M.setup()
	require("groups.common.notify").setup()
	require("groups.common.settings").setup()
	require("groups.common.autocmds").setup()
end

return M
