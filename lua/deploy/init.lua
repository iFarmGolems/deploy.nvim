local config = require("deploy.config")
local lib = require("deploy.lib")
local a = require("plenary.async")

local M = {}

M.setup = config.setup

vim.api.nvim_create_user_command("DeployToggleDeployOnSave", function()
  lib.toggle_deploy_on_save()
end, {})

vim.api.nvim_create_user_command("DeployCurrentFile", function()
  lib.deploy_file(vim.fn.expand("%:p"), false)
end, {})

vim.api.nvim_create_user_command("DeployCompareCurrentFile", function()
  lib.compare_via_rsync(vim.fn.expand("%:p"))
end, {})

vim.api.nvim_create_autocmd("BufWritePost", {
  callback = function(opts)
    if vim.g.DEPLOY_ON_SAVE then
      lib.deploy_file(opts.match, true)
    end
  end,
})

return M
