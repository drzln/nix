local M = {}

--[[
-- Check if there are non-whitespace characters before the cursor
-- @return boolean: true if non-whitespace characters exist before the cursor, false otherwise
local function has_words_before()
--]]
local function has_words_before()
	if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
		return false
	end
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
end

--[[
----- Check if 'kyazdani42/nvim-web-devicons' plugin is installed
-- @return boolean: true if the plugin is installed, false otherwise 
--]]
local function is_codicons_installed()
	local ok, _ = pcall(require, "nvim-web-devicons")
	return ok
end

--[[
----- Set up lspkind configuration based on the provided kind_config ("text" or "codicons")
-- @param kind_config string: The kind of configuration to set up (either "text" or "codicons")
--]]
-- local function set_lspkind_config(kind_config)
-- 	local symbol_map = {}
-- 	local lspkind = require("lspkind")
--
-- 	if kind_config == "text" then
-- 		symbol_map = M.getTextSymbolMap()
-- 	elseif kind_config == "codicons" and is_codicons_installed then
-- 		symbol_map = require("lspkind").presets.default
-- 	else
-- 		error("Invalid kind_config value, it must be 'text' or 'codicons'")
-- 	end
--
-- 	lspkind.init({ symbol_map = symbol_map })
-- 	M.setup()
-- end

--[[
-- get the local text symbol map
--]]
function M.getTextSymbolMap()
	return {
		Text = "[-]",
		Method = "[M]",
		Function = "[ƒ]",
		Constructor = "[C]",
		Field = "[.]",
		Variable = "[V]",
		Class = "[#]",
		Interface = "[I]",
		Module = "[M]",
		Property = "[P]",
		Unit = "[U]",
		Value = "[v]",
		Enum = "[E]",
		Keyword = "[K]",
		Snippet = "[S]",
		Color = "[C]",
		File = "[F]",
		Reference = "[R]",
		Folder = "[D]",
		EnumMember = "[e]",
		Constant = "[C]",
		Struct = "[S]",
		Event = "[@]",
		Operator = "[O]",
		TypeParameter = "[T]",
	}
end

--[[
-- completion key mappings
--]]
function M.getCmpMapping()
	local cmp = require("cmp")
	return {
		["<Tab>"] = vim.schedule_wrap(function(fallback)
			if cmp.visible() and has_words_before() then
				cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
			else
				fallback()
			end
		end),
		["<C-y>"] = cmp.config.disable,
		["<CR>"] = cmp.mapping.confirm({ select = true }),
		["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
		["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
		["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
		["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
		["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
		["<C-e>"] = cmp.mapping({ i = cmp.mapping.abort(), c = cmp.mapping.close() }),
	}
end

--[[
-- completion sources
--]]

function M.getCmpSources()
	return {
		{ name = "nvim_lsp" },
		-- { name = "luasnip" },
		-- { name = "copilot" },
		-- { name = "buffer" },
		-- { name = "cmdline" },
		-- { name = "treesitter" },
		-- { name = "path" },
	}
end

--[[
-- put it all together
--]]
function M.setup()
	vim.cmd([[ set completeopt=menu,menuone,noselect ]])
	-- set_lspkind_config("text")

	local cmp = require("cmp")
	-- local luasnip = require("luasnip")
	-- local lspkind = require("lspkind")
	cmp.setup({
		-- formatting = {
		-- 	-- format = lspkind.cmp_format({
		-- 	-- 	before = function(entry, vim_item)
		-- 	-- 		local source = entry.source.name
		-- 	-- 		vim_item.menu = string.format("%s (%s)", vim_item.menu or "", source)
		-- 	-- 		return vim_item
		-- 	-- 	end,
		-- 	-- }),
		-- },
		-- snippet = {
		-- 	expand = function(args)
		-- 		luasnip.lsp_expand(args.body)
		-- 	end,
		-- },
		mapping = {
			["<CR>"] = cmp.mapping(function(fallback)
				if cmp.visible() and cmp.get_active_entry() then
					-- Confirm currently active completion item
					cmp.confirm({ select = false })
					-- elseif luasnip.expand_or_jumpable() then
					-- Expand or jump in a snippet
					-- luasnip.expand_or_jump()
				else
					-- Just do a regular newline
					fallback()
				end
			end, { "i", "s" }),
			-- ["<Tab>"] = cmp.mapping(function(fallback)
			-- 	if cmp.visible() then
			-- 		cmp.select_next_item()
			-- 	else
			-- 		fallback()
			-- 	end
			-- end, { "i", "s" }),

			["<C-n>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				else
					fallback()
				end
			end, { "i", "s" }),

			-- ["<S-Tab>"] = cmp.mapping(function(fallback)
			-- 	if cmp.visible() then
			-- 		cmp.select_prev_item()
			-- 	else
			-- 		fallback()
			-- 	end
			-- end, { "i", "s" }),
		},
		sources = cmp.config.sources(M.getCmpSources()),
	})
end

return M
