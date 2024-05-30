local config = require("deploy.config")
local lib = require("deploy.lib")

local M = {}

M.setup = config.setup
M.deploy_current_file = lib.deploy_current_file

vim.api.nvim_create_user_command("DeployCurrentFile", function()
  M.deploy_current_file(false)
end, {})

return M
