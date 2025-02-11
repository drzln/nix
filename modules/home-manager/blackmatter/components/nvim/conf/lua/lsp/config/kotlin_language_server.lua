local M = {}

function M.setup(opts)
  local lsputils = require("lsp.utils")

  -- override kotlin_language_server
  local kotlin_language_server_opts = lsputils.merge(
    {},
    opts
  )

  -- enable kotlin_language_server
  require("lspconfig").kotlin_language_server.setup(kotlin_language_server_opts)
end

return M
