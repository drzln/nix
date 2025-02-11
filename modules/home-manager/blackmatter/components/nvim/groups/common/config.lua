local M = {}
function M.setup()
  -- set leader key
  vim.g.mapleader = ","

  -- highlight search results
  vim.opt.hlsearch = true
  
  -- customize file finding
  vim.opt.path:remove '/usr/include'
  vim.opt.path:append '**'
  vim.cmd [[set path=.,,,$PWD/**]]
  vim.opt.wildignorecase = true
  vim.opt.wildignore:append '**/node_modules/*'
  vim.opt.wildignore:append '**/.git/*'
  vim.opt.wildignore:append '**/build/*'

  -- highlight on yank
  vim.cmd [[
    augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
    augroup end
  ]]

  -- remember cursor position
  vim.cmd [[
    autocmd BufReadPost *
       \ if line("'\"") > 0 && line("'\"") <= line("$") |
       \   exe "normal! g`\"" |
       \ endif
  ]]

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
end

return M
