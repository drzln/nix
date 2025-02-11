local M = {}

function M.setup(opts)
  local lsputils = require("lsp.utils")
  local lspconfig = require("lspconfig")
  local configs = require("lspconfig.configs")

  -- override kcl
  local kcl_opts = lsputils.merge(
    {},
    opts
  )

  -- your base lspconfig does not have a kcl_lsp
  -- so give it one.
  if not configs.kcl_lsp then
    configs.kcl_lsp = {
      default_config = {
        cmd = { 'kcl-language-server', 'server', '--stdio' },
        filetypes = { 'kcl' },
        root_dir = lspconfig.util.root_pattern('.git'),
      },
      docs = {
        description = [=[
https://github.com/KittyCAD/kcl-lsp
https://kittycad.io

The KittyCAD Language Server Protocol implementation for the KCL language.

To better detect kcl files, the following can be added:


    vim.cmd [[ autocmd BufRead,BufNewFile *.kcl set filetype=kcl ]]

]=]      ,
        default_config = {
          root_dir = [[root_pattern(".git")]],
        },
      }
    }
  end

  -- enable _ansiblels
  lspconfig.kcl_lsp.setup(kcl_opts)
  vim.cmd [[ autocmd BufRead,BufNewFile *.kcl set filetype=kcl ]]
end

return M
