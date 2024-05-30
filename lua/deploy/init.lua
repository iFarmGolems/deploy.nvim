local config = require("deploy.config")
local lib = require("deploy.lib")

local M = {}

M.setup = config.setup

vim.api.nvim_create_user_command("DeployToggleDeployOnSave", function()
  lib.toggle_deploy_on_save()
end, {})

vim.api.nvim_create_user_command("DeployCurrentFile", function()
  lib.deploy_current_file(false)
end, {})

vim.api.nvim_create_autocmd("BufWritePost", {
  callback = function(opts)
    if vim.g.DEPLOY_ON_SAVE then
      lib.deploy_current_file(true, opts.match)
    end
  end,
})

return M
