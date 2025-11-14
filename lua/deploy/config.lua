local utils = require("deploy.utils")

local M = {}

---@type DeployConfig
M.defaults = {
  timeout = 3,
  hosts = {},
  mappings = {},
}

M.options = M.defaults

---@param opts DeployConfig
M.setup = function(opts)
  vim.g.DEPLOY_LAST_HOST = utils.get_last_host()
  vim.g.DEPLOY_ON_SAVE = vim.g.DEPLOY_ON_SAVE or false

  ---@type DeployConfig
  M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})

  -- sort options.mapping by length of fs descending to match the most specific path first
  table.sort(M.options.mappings, function(a, b)
    return #a.fs > #b.fs
  end)
end

return M
