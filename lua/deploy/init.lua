local config = require("deploy.config")
require("deploy.commands")

local M = {}

M.setup = config.setup

-- vim.api.nvim_create_user_command("DeployToggleDeployOnSave", function()
--   lib.toggle_deploy_on_save()
-- end, {})
--
-- vim.api.nvim_create_user_command("DeployCurrentFile", function()
--   lib.deploy_file(vim.fn.expand("%:p"))
-- end, {})
--
-- vim.api.nvim_create_user_command("DeployCompareCurrentFile", function()
--   lib.compare_via_rsync(vim.fn.expand("%:p"))
-- end, {})

-- vim.api.nvim_create_autocmd("BufWritePost", {
--   callback = function(opts)
--     if vim.g.DEPLOY_ON_SAVE then
--       lib.deploy_file(opts.match)
--     end
--   end,
-- })

-- vim.api.nvim_create_user_command("Deploy", function(opts)
--   local arguments = vim.split(opts.args or "", " ")
--
--   local subcommand = arguments[1]
--   local args = vim.list_slice(arguments, 2)
--
--   local actions = {
--     file = function()
--       lib.deploy_file(args[1] or vim.fn.expand("%:p"))
--     end,
--     toggle = function()
--       lib.toggle_deploy_on_save()
--     end,
--   }
--
--   actions[subcommand]()
-- end, { nargs = "?" })

return M
