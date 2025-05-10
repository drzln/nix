-- modules/home-manager/blackmatter/components/nvim/conf/init.lua
require("groups.common").setup()
require("groups.treesitter").setup()
require("groups.keybindings").setup()
require("groups.formatting").setup()
require("groups.completion").setup()
require("groups.lsp").setup()
require("groups.theming").setup()
