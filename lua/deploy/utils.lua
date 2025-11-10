local M = {}

---@return DeployHost|nil
M.get_last_host = function()
  return vim.g.DEPLOY_LAST_HOST or nil
end

---@param host DeployHost
M.set_last_host = function(host)
  assert(type(host) == "table" and host.address and host.label, "Invalid host object")
  vim.g.DEPLOY_LAST_HOST = host
end

---@return string
M.get_last_custom_address = function()
  return vim.g.DEPLOY_LAST_CUSTOM_ADDRESS or ""
end

---@param address string
M.set_last_custom_address = function(address)
  assert(type(address) == "string", "Address must be a string")
  vim.g.DEPLOY_LAST_CUSTOM_ADDRESS = address
end

return M
