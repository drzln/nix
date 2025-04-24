local M = {}
function M.setup()
	local mason = require("mason")
	local mason_lspconfig = require("mason-lspconfig")

	local function merge_configs(base, overrides)
		local merged = vim.tbl_deep_extend("force", {}, base, overrides)
		return merged
	end

	mason.setup()

	local mason_available_servers = mason_lspconfig.get_available_servers()
	local local_available_servers = {
		"ts_ls",
		-- "ruby_lsp",
	}
	local available_servers = merge_configs(mason_available_servers, local_available_servers)

	local exclude_servers = {
		"nil",
		"sqls",
		"pbls",
		"openscad_lsp",
		"pest_language_server",
		"starlark_rust",
		"svls",
		"glslls",
		"motoko_lsp",
		"jinja_lsp",
		"cucumber_language_server",
		"superhtml",
		"cairo_ls",
		"ginko_ls",
		"vhdl_ls",
		"starpls",
		"zk",
		"ruby_ls",
		"antlersls",
		"lwc_ls",
		"ltex",
		"biome",
		"htmx",
		"snyk_ls",
		"hydra_lsp",
		"ast_grep",
		"dprint",
		"stimulus_ls",
		"harper_ls",
		"gitlab_ci_ls",
		"hdl_checker",
		"coq_lsp",
		"typos_lsp",
		"ruff",
		"steep",
		"autotools_ls",
		"basedpyright",
		"emmet_ls",
		"emmet_language_server",
		"graphql_language_service_cli",
		"angularls",
		"ember",
		"eslint",
		"unocss",
		"tailwindcss",
		"cssmodules_ls",
		"glint",
		"vtsls",
		"taplo",
		"omnisharp_mono",
		"typst_lsp",
		"bufls",
		"solargraph",
		"rubocop",
		"pylsp",
		"cmake",
		"stylua",
		"standardrb",
		"efm",
		"pyre",
		"pylyzer",
		"ruff_lsp",
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
		"clarity_lsp",
		"awk_ls",
		"nimls",
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
		"ts_ls",
		"ruby_lsp",
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
