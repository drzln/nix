local M = {}

function M.setup()
  local utils = require('utils')
  -- find everything in this directory
  -- and run its setup hook.
  utils.load_files('~/.config/nvim/lua/plugins/config')

  -- TODO: make a part of utils.load_files
  require("lsp").setup()

  -- by default make gitblame on line off
  vim.cmd [[ let g:gitblame_enabled = 0 ]]

  -- recognize prisma files
  vim.cmd([[ au BufNewFile,BufRead *.prisma set filetype=prisma ]])

  -- load all language specific configs
  utils.load_files('~/.config/nvim/lua/config/langs')

  -- load testing configurations
  utils.load_files('~/.config/nvim/lua/config/testing')
end

return M
