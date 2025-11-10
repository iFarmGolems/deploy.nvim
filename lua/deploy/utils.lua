local M = {}

---@return DeployHost|nil
M.get_last_host = function()
  return vim.g.DEPLOY_LAST_HOST or nil
end

---@param host DeployHost
M.set_last_host = function(host)
  assert(type(host) == "table" and host.host and host.label, "Invalid host object")
  vim.g.DEPLOY_LAST_HOST = host
end

return M
