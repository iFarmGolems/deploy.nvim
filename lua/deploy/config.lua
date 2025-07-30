local M = {}

---@type DeployConfig
M.defaults = {
  timeout = 3,
  hosts = {},
  mapping = {},
}

M.options = M.defaults

---@param opts DeployConfig
M.setup = function(opts)
  vim.g.DEPLOY_LAST_HOST = vim.g.DEPLOY_LAST_HOST or "0.0.0.0"
  vim.g.DEPLOY_ON_SAVE = vim.g.DEPLOY_ON_SAVE or false

  ---@type DeployConfig
  M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

return M
