-- modules/home-manager/blackmatter/components/nvim/groups/completion/config.lua
local M = {}
local utils = require("completion.utils")

function M.setup_avante()
	local aws_profile = "pingersandbox01usw2" -- Replace with your actual profile name
	local aws_credentials, err = utils.read_aws_credentials_from_profile(aws_profile)
	local anthropic_api_key, api_key_err = utils.read_anthropic_api_key()

	if aws_credentials and anthropic_api_key then
		require("avante").setup({
			provider = "claude",
			model = "claude-3",
			provider_options = {
				aws_access_key_id = aws_credentials.aws_access_key_id,
				aws_secret_access_key = aws_credentials.aws_secret_access_key,
				aws_region = aws_credentials.aws_region,
				anthropic_api_key = anthropic_api_key,
				max_tokens = 4000,
				temperature = 0.7,
			},
			keymaps = {
				toggle_sidebar = "<leader>aa",
				ask_question = "<leader>aq",
			},
		})
	else
		print("Error: " .. (err or api_key_err))
	end
end

return M
