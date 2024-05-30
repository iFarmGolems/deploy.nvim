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

M.open_host_picker = function()
  local hosts = config.options.hosts
  local host_list = {}

  for idx, host in ipairs(hosts) do
    table.insert(host_list, idx .. ".) " .. host.label .. " (" .. host.host .. ")")
  end

  vim.fn.inputsave()
  local choice = vim.fn.inputlist(host_list)
  vim.fn.inputrestore()

  if choice == 0 then
    return false
  else
    vim.g.DEPLOY_LAST_HOST = hosts[choice].host

    return vim.g.DEPLOY_LAST_HOST
  end
end

M.toggle_deploy_on_save = function()
  vim.g.DEPLOY_ON_SAVE = not vim.g.DEPLOY_ON_SAVE

  if vim.g.DEPLOY_ON_SAVE then
    vim.notify("Deploy on save enabled", vim.log.levels.INFO)
  else
    vim.notify("Deploy on save disabled", vim.log.levels.INFO)
  end
end

M.prepare_for_deploy = function(file)
  if not M.is_deployable_file(file) then
    vim.notify("Not a deployable file", vim.log.levels.ERROR)
    return
  end

  local server_path = M.find_server_path(file)

  if not server_path then
    vim.notify("No server path found for " .. file, vim.log.levels.ERROR)
    return
  end

  local host_picked = M.open_host_picker()

  if not host_picked then
    return nil
  end

  vim.notify("Deploying...", vim.log.levels.INFO)

  return server_path
end

M.deploy_via_rsync = function(file)
  local server_path = M.prepare_for_deploy(file)

  if not server_path then
    return
  end

  Job:new({
    command = "rsync",
    args = { "-azhe", "ssh", file, "root@" .. vim.g.DEPLOY_LAST_HOST .. ":" .. server_path },
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        vim.notify("Deploy successful.", vim.log.levels.INFO)
      else
        vim.notify("Deploy failed.", vim.log.levels.ERROR)
      end
    end,
  }):start()
end

M.deploy_via_sftp = function(file)
  local server_path = M.prepare_for_deploy(file)

  if not server_path then
    return
  end

  Job:new({
    command = "sftp",
    args = { "root@" .. vim.g.DEPLOY_LAST_HOST },
    writer = function(job)
      job:send("put " .. file .. " " .. server_path .. "\n")
      job:send("exit\n")
    end,
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        vim.notify("Deploy successful.", vim.log.levels.INFO)
      else
        vim.notify("Deploy failed.", vim.log.levels.ERROR)
      end
    end,
  }):start()
end

M.deploy_current_file = function()
  local file = vim.fn.expand("%:p")
  local tool = config.options.tool or "sftp"

  local toolMap = {
    ["rsync"] = M.deploy_via_rsync,
  }

  toolMap[tool](file)
end

return M
