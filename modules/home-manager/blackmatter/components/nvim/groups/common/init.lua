-- modules/home-manager/blackmatter/components/nvim/groups/common/init.lua
local M = {}
function M.setup()
	local orig_notify = vim.notify
	vim.notify = function(msg, level, opts)
		if type(msg) == "string" and msg:match("vim.lsp.util.parse_snippet()") and msg:match("deprecated") then
			return
		end
		orig_notify(msg, level, opts)
	end
	vim.opt.wildignore:append("**/node_modules/*")
	vim.opt.wildignore:append("**/.git/*")
	vim.opt.wildignore:append("**/build/*")
	vim.g.mapleader = ","
	vim.opt.hlsearch = true
	vim.opt.path:remove("/usr/include")
	vim.opt.path:append("**")
	vim.cmd([[set path=.,,,$PWD/**]])
	vim.opt.wildignorecase = true
	vim.opt.relativenumber = true
	vim.opt.termguicolors = true
	vim.opt.timeoutlen = 300
	vim.opt.shiftwidth = 2
	vim.opt.expandtab = true
	vim.opt.tabstop = 2
	vim.cmd([[
    augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
    augroup end
  ]])
	vim.cmd([[
    autocmd BufReadPost *
       \ if line("'\"") > 0 && line("'\"") <= line("$") |
       \   exe "normal! g`\"" |
       \ endif
  ]])
end
return M
