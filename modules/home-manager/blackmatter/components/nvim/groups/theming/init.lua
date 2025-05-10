local M = {}
function M.setup()
	vim.opt.showtabline = 0
	vim.cmd([[colorscheme nord]])
	local base = "#2E3440"
	local popout = "#d8dee9"
	require("bufferline").setup({
		highlights = {
			separator = {
				bg = base,
				fg = popout,
			},
			fill = {
				bg = base,
			},
			background = {
				bg = base,
			},
			tab = {
				bg = base,
			},
			tab_selected = {
				bg = base,
				fg = popout,
			},
			tab_close = {
				bg = base,
			},
			close_button = {
				bg = base,
			},
			close_button_selected = {
				bg = base,
			},
			buffer_visible = {
				bg = base,
			},
			buffer_selected = {
				bg = base,
				fg = popout,
				bold = true,
			},
		},
		options = {
			numbers = "buffer_id",
			mode = "buffers",
			diagnostics = "nvim_lsp",
			separator_style = "thin",
			show_buffer_close_icons = false,
			show_close_icon = false,
			enforce_regular_tabs = false,
			always_show_bufferline = false,
			offsets = { {
				filetype = "NvimTree",
				text = "File Explorer",
				text_align = "left",
			} },
		},
	})
	require("lualine").setup({
		options = {
			theme = "nord",
			section_separators = { "", "" },
			component_separators = { "", "" },
			icons_enabled = true,
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = { "branch", "diff", "diagnostics" },
			lualine_c = { "filename" },
			lualine_x = { "encoding", "fileformat", "filetype" },
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
	})
end

return M
