local M = {}
function M.setup()
	-- Save the original notify function
	local orig_notify = vim.notify

	-- Override the global notify
	vim.notify = function(msg, level, opts)
		if type(msg) == "string" and msg:match("vim.lsp.util.parse_snippet()") and msg:match("deprecated") then
			return
		end
		orig_notify(msg, level, opts)
	end
	-- set leader key
	vim.g.mapleader = ","

	-- highlight search results
	vim.opt.hlsearch = true

	-- customize file finding
	vim.opt.path:remove("/usr/include")
	vim.opt.path:append("**")
	vim.cmd([[set path=.,,,$PWD/**]])
	vim.opt.wildignorecase = true
	vim.opt.wildignore:append("**/node_modules/*")
	vim.opt.wildignore:append("**/.git/*")
	vim.opt.wildignore:append("**/build/*")

	-- highlight on yank
	vim.cmd([[
    augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
    augroup end
  ]])

	-- remember cursor position
	vim.cmd([[
    autocmd BufReadPost *
       \ if line("'\"") > 0 && line("'\"") <= line("$") |
       \   exe "normal! g`\"" |
       \ endif
  ]])

	-- Time in milliseconds to wait for a mapped sequence to complete.
	vim.opt.timeoutlen = 300

	-- line number settings
	vim.opt.relativenumber = true

	-- Set the number of spaces a tab character represents
	vim.opt.tabstop = 2

	-- Set the number of spaces to use for each step of (auto)indent
	vim.opt.shiftwidth = 2

	-- Use spaces instead of tabs
	vim.opt.expandtab = true

	-- required for theming but cannot be in theming
	vim.opt.termguicolors = true

	-- telescope
	-- require('telescope').setup();

	-- require('telescope').load_extension('projects')
	-- projects
	-- require('project_nvim').setup {
	-- 	manual_mode = false,
	-- 	detection_methods = { 'lsp', 'pattern' },
	-- 	patterns = { '.git', '_darcs', '.hg', '.bzr', '.svn', 'Makefile', 'package.json' },
	-- };

	-- lualine
	require("lualine").setup({
		options = {
			theme = "nord",
			section_separators = { "", "" },
			component_separators = { "", "" },
			icons_enabled = true,
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = { "branch", "diff", "diagnostics" },
			lualine_c = { "filename" },
			lualine_x = { "encoding", "fileformat", "filetype" },
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
	})

	-- indent
	-- require('indent_blankline').setup {
	-- 	char = '▏',
	-- 	show_trailing_blankline_indent = false,
	-- 	show_current_context = true,
	-- 	show_current_context_start = true,
	-- }
end

return M
