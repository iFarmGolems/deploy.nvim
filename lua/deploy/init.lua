local config = require("deploy.config")
local lib = require("deploy.lib")

local M = {}

M.setup = config.setup
M.deploy_current_file = lib.deploy_current_file

vim.api.nvim_create_user_command("DeployTest", function()
  package.loaded.deploy = nil

  M.deploy_current_file()
end, {})

return M
