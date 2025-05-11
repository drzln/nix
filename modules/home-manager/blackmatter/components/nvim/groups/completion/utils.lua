-- modules/home-manager/blackmatter/components/nvim/groups/completion/utils.lua
local M = {}

function M.has_words_before()
	if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
		return false
	end
	local cursor = vim.api.nvim_win_get_cursor(0)
	local line = cursor[1]
	local col = cursor[2]

	return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
end

function M.read_file(file_path)
	local file = io.open(file_path, "r")
	if not file then
		return nil, "Error: Unable to open file " .. file_path
	end
	local content = file:read("*a")
	file:close()
	return content:match("^%s*(.-)%s*$")
end

function M.read_aws_credentials_from_profile(profile_name)
	local credentials = {}
	local config_file = os.getenv("HOME") .. "/.aws/config"
	local file = io.open(config_file, "r")
	if not file then
		return nil, "Error: Unable to open AWS config file: " .. config_file
	end

	local profile_found = false
	for line in file:lines() do
		if line:match("%[profile " .. profile_name .. "%]") then
			profile_found = true
		elseif profile_found then
			if line:match("aws_access_key_id") then
				credentials.aws_access_key_id = line:match("aws_access_key_id%s*=%s*(%S+)")
			elseif line:match("aws_secret_access_key") then
				credentials.aws_secret_access_key = line:match("aws_secret_access_key%s*=%s*(%S+)")
			elseif line:match("region") then
				credentials.aws_region = line:match("region%s*=%s*(%S+)")
			end
		end
	end
	file:close()

	if not profile_found then
		return nil, "Error: Profile [" .. profile_name .. "] not found."
	end
	if not credentials.aws_access_key_id or not credentials.aws_secret_access_key or not credentials.aws_region then
		return nil, "Error: Missing AWS credentials in profile [" .. profile_name .. "]"
	end

	return credentials
end

function M.read_anthropic_api_key()
	local api_key_file = os.getenv("HOME") .. "/.claude/neovim/anthropic_api_key"
	return M.read_file(api_key_file)
end

return M
