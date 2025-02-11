local M = {}

-- local excluded_filetypes = {
-- 	-- "rust", -- Add other filetypes if needed
-- }

function M.setup()
	local nls = require("null-ls")

	local nlssources = {
		-- nls.builtins.formatting.rustfmt,
		nls.builtins.formatting.phpcsfixer.with({
			command = "php-cs-fixer",
		}),
		nls.builtins.formatting.black,
		nls.builtins.formatting.prettier,
		nls.builtins.code_actions.gitsigns,
		nls.builtins.code_actions.eslint_d,
		nls.builtins.code_actions.gitrebase,
		nls.builtins.code_actions.refactoring,
		nls.builtins.formatting.terraform_fmt.with({
			filetypes = { "terraform", "tf", "hcl" },
		}),
		nls.builtins.formatting.shfmt.with({
			extra_args = { "-i", "2", "-sr" },
		}),
	}
	nls.setup({
		sources = nlssources,
		-- on_attach = function(client, bufnr)
		-- 	local ft = vim.bo.filetype
		-- 	for _, excluded_ft in ipairs(excluded_filetypes) do
		-- 		if ft == excluded_ft then
		-- 			client.stop()
		-- 			return
		-- 		end
		-- 	end
		-- end,
	})
end

return M
