local nio = require("nio")

local M = {}

M.debug = function(...)
  print(vim.inspect(...))
end

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

-- codes taken from `man rsync`
M.rsync_err_code_to_human = function(code)
  local error_code_map = {
    [4] = "Requested action not supported",
    [5] = "Error starting client-server protocol",
    [6] = "Daemon unable to append to log-file",
    [10] = "Error in socket I/O",
    [11] = "Error in file I/O",
    [12] = "Error in rsync protocol data stream",
    [13] = "Errors with program diagnostics",
    [14] = "Error in IPC code",
    [20] = "Received SIGUSR1 or SIGINT",
    [21] = "Some error returned by waitpid()",
    [22] = "Error allocating core memory buffers",
    [23] = "Partial transfer due to error",
    [24] = "Partial transfer due to vanished source files",
    [25] = "The --max-delete limit stopped deletions",
    [30] = "Timeout in data send/receive",
    [35] = "Timeout waiting for daemon connection",
  }

  return error_code_map[code] and error_code_map[code] or "Unknown error code: " .. tostring(code)
end

---Typed version of nio.create
---@generic F: function
---@param fn F
---@param arg_count integer
---@return F
M.nio_create = function(fn, arg_count)
  return nio.create(fn, arg_count)
end

return M
