local M = {}
function M.setup()
	require('lualine').setup({
		options = {
			theme = 'nord',
			section_separators = { '', '' },
			component_separators = { '', '' },
			icons_enabled = true,
		},
		sections = {
			lualine_a = { 'mode' },
			lualine_b = { 'branch', 'diff', 'diagnostics' },
			lualine_c = { 'filename' },
			lualine_x = { 'encoding', 'fileformat', 'filetype' },
			lualine_y = { 'progress' },
			lualine_z = { 'location' }
		},
	});
end

return M
