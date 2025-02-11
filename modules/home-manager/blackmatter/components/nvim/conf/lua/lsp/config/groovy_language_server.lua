local M = {}

function M.setup(opts)
  local lsputils = require("lsp.utils")
  local lspc = require("lspconfig")

  -- override groovy_language_server
  local groovy_language_server_opts = lsputils.merge(
    {
      cmd = { "groovy-language-server" },
      filetypes = { "groovy", "gradle" },
      root_dir = lspc.util.root_pattern("settings.gradle", ".git"),
      on_attach = function(_, bufnr)
        local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
        buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
      end,
      settings = {
        groovy = {
          configuration = {
            gradleEnabled = true,
          },
        },
      },
    },
    opts
  )

  -- enable groovy_language_server
  require("lspconfig").groovyls.setup(groovy_language_server_opts)
end

return M
