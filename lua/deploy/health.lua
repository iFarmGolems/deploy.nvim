local M = {}

local rsync_exists = vim.fn.executable("rsync")
local sftp_exists = vim.fn.executable("sftp")

local function check_tools()
  if not rsync_exists then
    vim.health.warning("rsync executable not found")
  else
    vim.health.ok("rsync executable found")
  end

  if not sftp_exists then
    vim.health.warning("sftp executable not found")
  else
    vim.health.ok("sftp executable found")
  end

  if not rsync_exists or not sftp_exists then
    vim.health.error("No available deploy tools found!")
  end
end

M.check = function()
  check_tools()
end

return M
