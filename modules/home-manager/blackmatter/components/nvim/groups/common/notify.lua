-- modules/home-manager/blackmatter/components/nvim/groups/common/notify.lua
local M = {}

function M.setup()
	local orig_notify = vim.notify
	vim.notify = function(msg, level, opts)
		if type(msg) == "string" and msg:match("vim.lsp.util.parse_snippet()") and msg:match("deprecated") then
			return
		end
		orig_notify(msg, level, opts)
	end
end

return M
