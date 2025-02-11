local M = {}

-- merge tables
function M.merge(t1, t2)
	for k, v in pairs(t2) do
		t1[k] = v
	end

	return t1
end

-- contains
function M.set_contains(set, val)
	for _, value in pairs(set) do
		if value == val then
			return true
		end
	end
	return false
end

-- top-level on_attach function that gets passed to each language server
function M.lsp_attach(client, bufnr)
	M.lsp_config(client, bufnr)
end


function M.lsp_config(client, _)
	-- disable formatting completely by language servers
	client.server_capabilities.documentFormattingProvider = false
	client.server_capabilities.documentRangeFormattingProvider = false
end

return M
