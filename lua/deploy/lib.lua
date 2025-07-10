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
          default = vim.g.DEPLOY_LAST_HOST or "",
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
          vim.notify("Failed to create directory: " .. server_path .. " on remote host.", vim.log.levels.ERROR)
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

  vim.notify("Creating directory " .. server_dir .. " on " .. host .. "...")

  vim.system({ "ssh", "root@" .. host, "mkdir -p " .. server_dir }, { text = true }, function(handle)
    if handle.code == 0 then
      callback(true)
    else
      vim.notify("Failed to create directory " .. server_dir .. " on " .. host, vim.log.levels.ERROR)
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

M.diff_buffer_with_string = function(str)
  -- Create a new buffer for the string
  local diff_buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_buf_set_lines(diff_buf, 0, -1, false, vim.split(str, "\n"))

  -- Open a vertical split with the new buffer
  vim.cmd("vsplit")
  vim.api.nvim_win_set_buf(0, diff_buf)

  -- Enable diff mode for both buffers
  vim.cmd("diffthis")
  vim.cmd("wincmd p") -- Switch back to the original buffer
  vim.cmd("diffthis")

  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(vim.api.nvim_get_current_win()),
    callback = function()
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(diff_buf) then
          vim.api.nvim_buf_delete(diff_buf, { force = true }) -- Forcefully delete the buffer
        end
      end)
    end,
    once = true, -- Ensure the autocommand runs only once
  })
end

M.compare_with_remote_file = a.void(function()
  local current_file = vim.fn.expand("%:p")
  local server_path = M.get_server_path(current_file)
  local host = M.pick_host()

  if not server_path then
    vim.notify("No mapping found for " .. current_file, vim.log.levels.ERROR)
    return
  end

  if not host then
    vim.notify("Abort: No host selected", vim.log.levels.WARN)
    return
  end

  local fetch_command = {
    "ssh",
    "root@" .. host,
    "cat " .. server_path .. " > /tmp/nvim-deploy-compare-content",
  }

  vim.system(fetch_command, { text = true }, function(fetch_handle)
    if fetch_handle.code == 0 then
      vim.schedule(function()
        local current_file_text = vim.fn.join(vim.fn.readfile(current_file), "\n")
        local remote_text = vim.fn.join(vim.fn.readfile("/tmp/nvim-deploy-compare-content"), "\n")

        if current_file_text == remote_text then
          vim.notify("No differences found.")
          return
        else
          M.diff_buffer_with_string(remote_text)
        end
      end)
    else
      vim.notify(
        "Failed to fetch remote file!\nExit code: " .. fetch_handle.code .. ".\nSTDERR: " .. fetch_handle.stderr,
        vim.log.levels.ERROR
      )
    end
  end)
end)

return M
