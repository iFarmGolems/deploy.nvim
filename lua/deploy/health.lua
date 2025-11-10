local M = {}

local rsync_exists = vim.fn.executable("rsync")

local function check_cli_tools()
  if not rsync_exists then
    vim.health.error("rsync executable not found - deploy will not work")
  else
    vim.health.ok("rsync executable found")
  end
end

local function check_config()
  local deploy_config = require("deploy.config").options

  if #deploy_config.hosts == 0 then
    vim.health.warn("No deploy hosts configured")
  else
    for _, host in ipairs(deploy_config.hosts) do
      if not host.address or not host.label then
        vim.health.error("Deploy host is missing address or label")
        return
      end
    end
  end

  if #deploy_config.mapping == 0 then
    vim.health.error("No deploy mappings configured")
  else
    for _, map in ipairs(deploy_config.mapping) do
      if not map.fs or not map.remote then
        vim.health.error("Deploy mapping is missing fs or remote path")
        return
      end
    end
  end
end

M.check = function()
  check_cli_tools()
  check_config()
end

return M
