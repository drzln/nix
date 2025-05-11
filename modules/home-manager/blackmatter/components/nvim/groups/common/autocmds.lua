-- modules/home-manager/blackmatter/components/nvim/groups/common/autocmds.lua
local M = {}

function M.setup()
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
