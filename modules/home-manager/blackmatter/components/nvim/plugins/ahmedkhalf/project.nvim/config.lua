local M = {}
function M.setup()
	require('project_nvim').setup {
		manual_mode = false,
		detection_methods = { 'lsp', 'pattern' },
		patterns = { '.git', '_darcs', '.hg', '.bzr', '.svn', 'Makefile', 'package.json' },
	};
end

return M
