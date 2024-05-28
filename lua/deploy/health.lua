local M = {}

local rsync_exists = vim.fn.executable("rsync")
local sftp_exists = vim.fn.executable("sftp")

local function check_rsync()
	if !rsync_exists then
		vim.health.warning("rsync executable not found")
	else
		vim.health.ok("rsync executable found")
	end
end

local function check_sftp()
	if !sftp_exists then
		vim.health.warning("sftp executable not found")
	else
		vim.health.ok("sftp executable found")
	end
end

local function check_both()
  if rsync_exists or sftp_exists then
    vim.health.ok("rsync and/or sftp executables found")
  else
    vim.health.error("rsync and/or sftp executables not found")
  end
end

M.check = function()
	check_rsync()
	check_sftp()
  check_both()
end

return M