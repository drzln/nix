local M = {}
function M.setup()
	local base = "#2E3440"
	local popout = "#d8dee9"
	require("bufferline").setup {
		highlights = {
			separator = {
				bg = base,
				fg = popout
			},
			fill = {
				bg = base
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
			diagnostics = "nvim_lsp",
			separator_style = "thin",
			show_buffer_close_icons = true,
			show_close_icon = true,
			enforce_regular_tabs = false,
			always_show_bufferline = true,
			offsets = { {
				filetype = "NvimTree",
				text = "File Explorer",
				text_align = "left",
			} },
		}
	}
end

return M
