-- modules/home-manager/blackmatter/components/nvim/groups/common/settings.lua
local M = {}

function M.setup()
	vim.opt.wildignore:append("**/node_modules/*")
	vim.opt.wildignore:append("**/.git/*")
	vim.opt.wildignore:append("**/build/*")
	vim.opt.wildignorecase = true
	vim.opt.hlsearch = true
	vim.opt.relativenumber = true
	vim.opt.termguicolors = true
	vim.opt.timeoutlen = 300
	vim.opt.shiftwidth = 2
	vim.opt.expandtab = true
	vim.opt.tabstop = 2
	vim.g.mapleader = ","
	vim.opt.path:remove("/usr/include")
	vim.opt.path:append("**")
	vim.cmd([[set path=.,,,$PWD/**]])
end

return M
