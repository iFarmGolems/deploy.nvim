local M = {}

local rsync_exists = vim.fn.executable("rsync")
local sftp_exists = vim.fn.executable("sftp")

local function check_rsync()
  if not rsync_exists then
    vim.health.warning("rsync executable not found")
  else
    vim.health.ok("rsync executable found")
  end
end

local function check_sftp()
  if not sftp_exists then
    vim.health.warning("sftp executable not found")
  else
    vim.health.ok("sftp executable found")
  end
end

M.check = function()
  check_rsync()
  check_sftp()
end

return M
