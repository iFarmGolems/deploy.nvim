local config = require("deploy.config")
local a = require("plenary.async")

local M = {}

M.is_deployable = function(file_path)
  return vim.fn.filereadable(file_path) == 1 and vim.fn.isdirectory(file_path) == 0
end

M.get_server_path = function(file_path)
  if not M.is_deployable(file_path) then
    return nil
  end

  local mapping = config.options.mapping
  local server_path = nil

  -- Sort the mapping by fs length in descending order
  -- so that we can match the most specific path first
  table.sort(mapping, function(x, y)
    return #x.fs > #y.fs
  end)

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

M.pick_host = a.wrap(function(callback)
  ---append host "other" to the list of hosts
  local hosts = vim.deepcopy(config.options.hosts)
  table.insert(hosts, 1, { label = "Other", host = "CUSTOM_HOST" })

  vim.ui.select(hosts, {
    prompt = "Select host:",
    format_item = function(item)
      return item.label .. " (" .. item.host .. ")"
    end,
  }, function(choice)
    if choice then
      if choice.host == "CUSTOM_HOST" then
        vim.ui.input({
          prompt = "Enter host:",
          default = "",
        }, function(host)
          if host then
            vim.g.DEPLOY_LAST_HOST = host
            callback(host)
          else
            callback(nil)
          end
        end)
        return
      end

      vim.g.DEPLOY_LAST_HOST = choice.host
      callback(choice.host)
    else
      callback(nil)
    end
  end)
end, 1)

M.toggle_deploy_on_save = function()
  vim.g.DEPLOY_ON_SAVE = not vim.g.DEPLOY_ON_SAVE

  if vim.g.DEPLOY_ON_SAVE then
    vim.notify("Deploy on save enabled", vim.log.levels.INFO)
  else
    vim.notify("Deploy on save disabled", vim.log.levels.INFO)
  end
end

M.transfer = function(opts)
  local file, server_path, host = unpack(opts)

  local command = {
    "rsync",
    "--timeout=" .. config.options.timeout,
    "-avze",
    "ssh",
    file,
    "root@" .. host .. ":" .. server_path,
  }

  vim.notify("Deploying to " .. host .. "...")

  vim.system(command, { text = true }, function(handle)
    if handle.code == 0 then
      vim.notify("Deploy successful.")
    elseif handle.code == 3 then
      M.create_server_dir(server_path, host, function(success)
        if success then
          M.transfer(opts)
        else
          vim.notify("Failed to create server directory", vim.log.levels.ERROR)
        end
      end)
    else
      vim.notify("Deploy failed!\nExit code: " .. handle.code .. ".\nSTDERR: " .. handle.stderr, vim.log.levels.ERROR)
      print("Command used: ", table.concat(command, " "))
    end
  end)
end

M.create_server_dir = function(server_path, host, callback)
  local server_dir = server_path:match("(.*/)")

  vim.system({ "ssh", "root@" .. host, "mkdir -p " .. server_dir }, { text = true }, function(handle)
    if handle.code == 0 then
      callback(true)
    else
      callback(false)
    end
  end)
end

M.deploy_file = a.void(function(file)
  local server_path = M.get_server_path(file)

  if not server_path then
    vim.notify("No mapping found for " .. file, vim.log.levels.ERROR)

    return
  end

  local host = M.pick_host()

  if not host then
    vim.notify("Abort: No host selected", vim.log.levels.WARN)
    return
  end

  M.transfer({ file, server_path, host })
end)

M.auto_deploy_file = function(file)
  local server_path = M.get_server_path(file)
  local host = vim.g.DEPLOY_LAST_HOST

  if server_path then
    M.transfer({ file, server_path, host })
  end
end

return M
