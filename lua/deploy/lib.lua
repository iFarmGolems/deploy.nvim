local config = require("deploy.config")
local Job = require("plenary.job")

local M = {}

M.is_deployable_file = function(file_path)
  if vim.fn.filereadable(file_path) == 0 then
    return false
  end
  if vim.fn.isdirectory(file_path) == 1 then
    return false
  end
  return true
end

M.find_server_path = function(file_path)
  local mapping = config.options.mapping
  local server_path = nil

  for _, map in ipairs(mapping) do
    local fs = vim.fn.expand(map.fs)
    -- if file_path starts with fs then we can deploy it
    if file_path:find(fs, 1, true) == 1 then
      server_path = file_path:gsub(fs, map.remote)
      break
    end
  end

  return server_path
end

M.deploy_via_rsync = function(file)
  if not M.is_deployable_file(file) then
    vim.notify("Not a deployable file", vim.log.levels.ERROR)
    return
  end

  local server_path = M.find_server_path(file)

  if not server_path then
    vim.notify("No server path found for " .. file, vim.log.levels.ERROR)
    return
  end

  vim.notify("root@" .. vim.g.DEPLOY_LAST_HOST .. ":" .. server_path, vim.log.levels.INFO)

  Job:new({
    command = "rsync",
    args = { "-azhe", "ssh", file, "root@" .. vim.g.DEPLOY_LAST_HOST .. ":" .. server_path },
    on_exit = function(j, return_val)
      vim.notify(j:result())

      if return_val == 0 then
        vim.notify("Deployed " .. file, vim.log.levels.INFO)
      else
        vim.notify("Failed to deploy " .. file, vim.log.levels.ERROR)
      end
    end,
  }):start()
end

M.deploy_current_file = function()
  local file = vim.fn.expand("%:p")
  M.deploy_via_rsync(file)
end

return M
