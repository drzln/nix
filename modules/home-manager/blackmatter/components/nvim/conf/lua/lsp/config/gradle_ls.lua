local M = {}

function M.setup(opts)
  local lsputils = require("lsp.utils")

  -- override gradlels
  local gradlels_opts = lsputils.merge(
    {},
    opts
  )

  -- enable _ansiblels
  require("lspconfig").gradle_ls.setup(gradlels_opts)
end

return M
