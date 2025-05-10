local M = {}

function M.setup()
	local opts = { noremap = true, silent = true }

	-- Normal mode keybindings
	-- vim.keymap.set('n', '<C-h>', '<C-w>h', opts) -- Move to left window
	-- vim.keymap.set('n', '<C-j>', '<C-w>j', opts) -- Move to below window
	-- vim.keymap.set('n', '<C-k>', '<C-w>k', opts) -- Move to above window
	-- vim.keymap.set('n', '<C-l>', '<C-w>l', opts) -- Move to right window

	-- Telescope keybindings (plugin-dependent)
	-- vim.keymap.set('n', '<Leader>fi', '<Cmd>Telescope find_files<CR>', opts)
	-- vim.keymap.set('n', '<Leader>fg', '<Cmd>Telescope live_grep<CR>', opts)
	-- vim.keymap.set('n', '<Leader>fb', '<Cmd>Telescope buffers<CR>', opts)
	-- vim.keymap.set('n', '<Leader>fh', '<Cmd>Telescope help_tags<CR>', opts)
	-- vim.keymap.set('n', '<Leader>gb', '<Cmd>Telescope git_branches<CR>', opts)
	-- vim.keymap.set('n', '<Leader>gc', '<Cmd>Telescope git_commits<CR>', opts)
	-- vim.keymap.set('n', '<Leader>gr', '<Cmd>Telescope lsp_references<CR>', opts)
	-- vim.keymap.set('n', '<Leader>gd', '<Cmd>Telescope lsp_definitions<CR>', opts)
	-- vim.keymap.set('n', '<Leader>fc', '<Cmd>Telescope command_history<CR>', opts)
	-- vim.keymap.set('n', '<Leader>fk', '<Cmd>Telescope keymaps<CR>', opts)
	-- vim.keymap.set('n', '<Leader>fs', '<Cmd>Telescope search_history<CR>', opts)
	-- vim.keymap.set('n', '<Leader>fp', '<Cmd>Telescope projects<CR>', opts)

	-- ff key triggers conform formatting framework
	local conform = require("conform")
	vim.keymap.set("n", "ff", conform.format, opts)
end

return M
