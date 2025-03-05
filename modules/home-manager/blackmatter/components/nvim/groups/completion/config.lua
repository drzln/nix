local M = {}

-- Function to read a single file's content (to read the API key from a file)
local function read_file(file_path)
	local file = io.open(file_path, "r")
	if not file then
		return nil, "Error: Unable to open file " .. file_path
	end
	local content = file:read("*a") -- Read the entire content of the file
	file:close()
	return content:match("^%s*(.-)%s*$") -- Trim leading/trailing spaces
end

-- Function to read AWS credentials from a profile in the AWS config file
local function read_aws_credentials_from_profile(profile_name)
	local credentials = {}

	-- Define the path to the AWS config file
	local config_file = os.getenv("HOME") .. "/.aws/config"

	-- Open the file and read its contents
	local file = io.open(config_file, "r")
	if not file then
		return nil, "Error: Unable to open AWS config file: " .. config_file
	end

	local profile_found = false
	for line in file:lines() do
		-- Look for the profile section
		if line:match("%[profile " .. profile_name .. "%]") then
			profile_found = true
		elseif profile_found then
			-- Extract aws_access_key_id, aws_secret_access_key, and region from the profile section
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

	-- If the profile was found but we don't have the credentials, report an error
	if not profile_found then
		return nil, "Error: Profile [" .. profile_name .. "] not found in config file."
	end

	-- If any required fields are missing, return an error
	if not credentials.aws_access_key_id or not credentials.aws_secret_access_key or not credentials.aws_region then
		return nil, "Error: Missing AWS credentials in profile [" .. profile_name .. "]"
	end

	return credentials
end

-- Function to read the Anthropic API key from a file
local function read_anthropic_api_key()
	local api_key_file = os.getenv("HOME") .. "/.claude/neovim/anthropic_api_key" -- Path to your API key file
	return read_file(api_key_file)
end

-- Read the AWS credentials from the profile in the AWS config file
local aws_profile = "pingersandbox01usw2" -- Replace with your actual profile name
local aws_credentials, err = read_aws_credentials_from_profile(aws_profile)

-- Read the Anthropic API key from file
-- local anthropic_api_key, api_key_err = read_anthropic_api_key()

-- if aws_credentials and anthropic_api_key then
-- 	-- Configure Avante.nvim with Claude Sonnet via Amazon Bedrock and Anthropic API key
-- 	-- require("avante").setup({
-- 	-- 	provider = "claude", -- Use Claude as the AI provider
-- 	-- 	model = "claude-3", -- Use Claude 3 model (or change to your preferred version)
-- 	-- 	provider_options = {
-- 	-- 		aws_access_key_id = aws_credentials.aws_access_key_id, -- Read from the profile
-- 	-- 		aws_secret_access_key = aws_credentials.aws_secret_access_key, -- Read from the profile
-- 	-- 		aws_region = aws_credentials.aws_region, -- Read from the profile
-- 	-- 		anthropic_api_key = anthropic_api_key, -- Directly use the Anthropic API key from file
-- 	-- 		max_tokens = 4000, -- Maximum tokens for response (adjust as needed)
-- 	-- 		temperature = 0.7, -- Adjust response creativity (higher = more creative)
-- 	-- 	},
-- 	-- 	-- Additional configurations for the Avante sidebar or general settings
-- 	-- 	keymaps = {
-- 	-- 		toggle_sidebar = "<leader>aa", -- Keybinding to toggle the Avante sidebar
-- 	-- 		ask_question = "<leader>aq", -- Keybinding to ask the AI a question
-- 	-- 	},
-- 	-- })
-- else
-- 	print("Error: " .. (err or api_key_err))
-- end

return M
