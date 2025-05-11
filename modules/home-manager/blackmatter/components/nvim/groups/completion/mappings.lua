-- modules/home-manager/blackmatter/components/nvim/groups/completion/mappings.lua
local M = {}
local cmp = require("cmp")
local utils = require("completion.utils")

function M.get()
	return {
		["<CR>"] = cmp.mapping(function(fallback)
			if cmp.visible() and cmp.get_active_entry() then
				cmp.confirm({ select = false })
			else
				fallback()
			end
		end, { "i", "s" }),

		["<Tab>"] = vim.schedule_wrap(function(fallback)
			if cmp.visible() and utils.has_words_before() then
				cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
			else
				fallback()
			end
		end),

		["<C-n>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end, { "i", "s" }),

		["<C-y>"] = cmp.config.disable,
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
	}
end

return M
