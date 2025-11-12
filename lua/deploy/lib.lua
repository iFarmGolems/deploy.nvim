local config = require("deploy.config")
local utils = require("deploy.utils")
local nio = require("nio")

local M = {
  shell = {},
}

---@param opts {msg: string, level?: integer, silent?: boolean}
M.notify = function(opts)
  local silent = opts.silent or false

  if silent then
    return
  end

  local msg = opts.msg or ""
  local level = opts.level or vim.log.levels.INFO

  vim.notify("[[Deploy]] " .. msg, level)
end

---@type fun(context: DeployContext): ShellCommandResult
M.shell.fire_rsync = nio.create(
  ---@param context DeployContext
  function(context)
    local rsync_args = {
      "--timeout=" .. config.options.timeout,
      "-avze",
      "ssh",
      context.source,
      "root@" .. context.address .. ":" .. context.destination,
    }

    return utils.run_shell_command({
      cmd = "rsync",
      args = rsync_args,
    })
  end,
  1
)

---@type fun(context: DeployContext): ShellCommandResult
M.shell.create_remote_dir = nio.create(
  ---@param context DeployContext
  function(context)
    local ssh_args = {
      "root@" .. context.address,
      "mkdir -p " .. context.destination:match("(.*/)"),
    }

    return utils.run_shell_command({
      cmd = "ssh",
      args = ssh_args,
    })
  end,
  1
)

---@type fun(): DeployHost|nil
M.pick_host = nio.create(function()
  local hosts = vim.deepcopy(config.options.hosts)
  local last_custom_address = utils.get_last_custom_address()

  local CUSTOM_HOST = { label = "Custom", address = last_custom_address, is_custom = true }

  table.insert(hosts, 1, CUSTOM_HOST)

  ---@type {label: string, address: string, is_custom: boolean}|nil
  local host = nio.ui.select(hosts, {
    prompt = "Select host:",
    format_item = function(item)
      local has_address = item.address and item.address ~= ""

      return item.label .. (has_address and " (" .. item.address .. ")" or "")
    end,
  })

  if host then
    if host.is_custom then
      local custom_host_address = nio.ui.input({
        prompt = "Enter address:",
        default = last_custom_address,
        highlight = function() end,
      })

      if custom_host_address then
        CUSTOM_HOST.address = custom_host_address
        utils.set_last_custom_address(custom_host_address)
        utils.set_last_host(CUSTOM_HOST)

        return CUSTOM_HOST
      else
        return nil
      end
    end

    utils.set_last_host(host)

    return host
  else
    return nil
  end
end, 0)

---@type fun(source: string, options?: DeployOptions): nil
M.deploy_file = nio.create(function(source, options)
  options = options or {}

  local mapping = M.get_file_mapping(source)

  if not mapping then
    M.notify({ msg = "No mapping found for file: " .. source, level = vim.log.levels.ERROR, silent = options.silent })
    return
  end

  local host = options.deploy_to_last_host and utils.get_last_host() or M.pick_host()

  if not host then
    M.notify({ msg = "Aborting deploy: No host selected", level = vim.log.levels.WARN, silent = options.silent })
    return
  end

  local destination = mapping.remote .. source:sub(#vim.fn.expand(mapping.fs) + 1)

  ---@type RewriteFunctionContext
  local context = {
    source = source,
    destination = destination,
    address = host.address,
    extension = source:match("^.+(%..+)$"),
  }

  if mapping.rewrite then
    local rewrite_result = mapping.rewrite(context)

    if not rewrite_result then
      M.notify({
        msg = "Aborting deploy: Mapping rewrite function returned false",
        level = vim.log.levels.WARN,
        silent = options.silent,
      })
      return
    end
  end

  if host.rewrite then
    local rewrite_result = host.rewrite(context)

    if not rewrite_result then
      M.notify({
        msg = "Aborting deploy: Host rewrite function returned false",
        level = vim.log.levels.WARN,
        silent = options.silent,
      })
      return
    end
  end

  local rsync_res = M.shell.fire_rsync(context)

  if rsync_res.code == 0 then
    M.notify({ msg = "Deploy successful (" .. context.address .. ")" })
    return
  end

  -- handle known status codes for missing remote directory
  if rsync_res.code == 3 or rsync_res.code == 12 then
    M.notify({
      msg = "Remote directory does not exist. Creating...",
      level = vim.log.levels.WARN,
    })

    local dir_res = M.shell.create_remote_dir(context)

    if dir_res.code == 0 then
      M.notify({ msg = "Remote directory created. Retrying deploy..." })
      rsync_res = M.shell.fire_rsync(context)

      if rsync_res.code == 0 then
        M.notify({ msg = "Deploy successful (" .. context.address .. ")" })
        return
      else
        M.notify({
          msg = "Deploy failed after creating directory: " .. rsync_res.out,
          level = vim.log.levels.ERROR,
        })
        return
      end
    else
      M.notify({
        msg = "Failed to create remote directory: " .. dir_res.out,
        level = vim.log.levels.ERROR,
      })

      return
    end
  end

  M.notify({
    msg = "Deploy failed! Unable to handle rsync exit code: "
      .. rsync_res.code
      .. "\n\nCommand used: \n"
      .. rsync_res.command
      .. "\n\nOutput:\n"
      .. utils.rsync_err_code_to_human(rsync_res.code),
    level = vim.log.levels.ERROR,
  })
end, 2)

M.is_deployable = function(source)
  return vim.fn.filereadable(source) == 1 and vim.fn.isdirectory(source) == 0
end

---@return DeployMapping|nil
M.get_file_mapping = function(source)
  if not M.is_deployable(source) then
    return nil
  end

  local deploy_mappings = config.options.mapping
  local found_mapping = nil

  for _, mapping in ipairs(deploy_mappings) do
    local fs = vim.fn.expand(mapping.fs)

    if source:find(fs, 1, true) == 1 then
      found_mapping = mapping
      break
    end
  end

  return found_mapping
end

---@param override? boolean If provided, sets the flag to this value
M.toggle_deploy_on_save = function(override)
  if override ~= nil then
    vim.g.DEPLOY_ON_SAVE = override
  else
    vim.g.DEPLOY_ON_SAVE = not vim.g.DEPLOY_ON_SAVE
  end

  if vim.g.DEPLOY_ON_SAVE then
    M.notify({ msg = "Deploy on save enabled" })
  else
    M.notify({ msg = "Deploy on save disabled" })
  end
end

return M
