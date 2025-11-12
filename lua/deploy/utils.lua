local nio = require("nio")

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

---@type fun(opts: nio.process.RunOpts): ShellCommandResult
M.run_shell_command = nio.create(
  ---@param opts nio.process.RunOpts
  function(opts)
    local process = nio.process.run(opts)

    if process == nil then
      return { -1, "Failed to start process '" .. opts.cmd .. "'" }
    end

    local code = process.result(true)
    local out = code == 0 and process.stdout.read() or process.stderr.read() or ""

    return { code = code, out = out, command = opts.cmd .. " " .. table.concat(opts.args or {}, " ") }
  end,
  1
)

M.debug = function(...)
  print(vim.inspect(...))
end

return M
