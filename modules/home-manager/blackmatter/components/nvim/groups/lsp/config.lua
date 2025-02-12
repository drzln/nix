local M = {}
function M.setup()
	local mason = require("mason")
	local mason_lspconfig = require("mason-lspconfig")

	mason.setup()

	local available_servers = mason_lspconfig.get_available_servers()

	local exclude_servers = {
		"taplo",
		"omnisharp_mono",
		"typst_lsp",
		"bufls",
		-- "solargraph",
		"rubocop",
		"stylua",
		"standardrb",
		"efm",
		"pyre",
		"pylyzer",
		"ruff_lsp",
		"pyright",
		"jedi_language_server",
		"mm0_ls",
		"lelwel_ls",
		"flux_lsp",
		"vls",
		"verible",
		"fennel_language_server",
		"rome",
		"diagnosticls",
		"spectral",
		"azure_pipelines_ls",
		"tflint",
		"remark_ls",
		"marksman",
		"prosemd_lsp",
		"vale_ls",
		"grammarly",
		"custom_elements_ls",
		"pkgbuild_language_server",
		-- "nil_ls",
		"rnix",
		"sorbet",
		"sourcery",
		"erlangls",
		"teal_ls",
		"foam_ls",
		"asm_lsp",
		"beancount",
		"salt_ls",
		"java_language_server",
		"move_analyzer",
		"r_language_server",
		"ruby_ls",
		"clarity_lsp",
		"awk_ls",
		"nimls",
		"tsserver",
		"ocamllsp",
		"csharp_ls",
		"vala_ls",
		"vuels",
		"hls",
		"denols",
		"quick_lint_js",
		"als",
	}

	local configure_only_servers = {
		"rust_analyzer",
	}

	local function is_excluded(server)
		return vim.tbl_contains(exclude_servers, server)
	end

	local function is_configure_only(server)
		return vim.tbl_contains(configure_only_servers, server)
	end

	local servers_to_install = vim.tbl_filter(function(server)
		return not is_excluded(server) and not is_configure_only(server)
	end, available_servers)

	mason_lspconfig.setup({
		ensure_installed = servers_to_install,
		automatic_installation = false,
	})

	local lspconfig = require("lspconfig")

	local server_configs = {
		lua_ls = {
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim" },
					},
				},
			},
		},
	}

	local function merge_configs(base, overrides)
		local merged = vim.tbl_deep_extend("force", {}, base, overrides)
		return merged
	end

	local common_config = {
		capabilities = require("cmp_nvim_lsp").default_capabilities(),
	}

	for _, server in ipairs(available_servers) do
		if not is_excluded(server) then
			local success, err = pcall(function()
				local config = server_configs[server] or {}
				local final_config = merge_configs(common_config, config)
				lspconfig[server].setup(final_config)
			end)
			if not success then
				print("Error setting up " .. server .. ": " .. err)
			end
		end
	end
end

return M
