local M = {}
function M.setup()
	require('telescope').load_extension('projects')
	require('telescope').setup();
end

return M
