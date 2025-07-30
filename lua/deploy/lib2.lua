local nio = require("nio")
local config = require("deploy.config")

local M = {}

local is_deployable_cache = {}

M.is_deployable = function(local_file_path)
  if is_deployable_cache[local_file_path] ~= nil then
    return is_deployable_cache[local_file_path]
  end

  local is_file = vim.fn.filereadable(local_file_path) == 1
  local is_not_dir = vim.fn.isdirectory(local_file_path) == 0

  local result = is_file and is_not_dir

  is_deployable_cache[local_file_path] = result

  return result
end

-- Returns the remote path for the given local file path.
-- If the file is not deployable, returns nil.
M.get_server_path = function(local_file_path)
  if not M.is_deployable(local_file_path) then
    return nil
  end

  local mappings = config.options.mapping

  -- Sort the mapping by fs length in descending order
  -- so that we can match the most specific path first
  table.sort(mappings, function(x, y)
    return #x.fs > #y.fs
  end)

  local server_path = nil

  for _, mapping in ipairs(mappings) do
    local fs = vim.fn.expand(mapping.fs)

    -- if file_path matches any declared "fs" then we can deploy it
    if local_file_path:find(fs, 1, true) == 1 then
      server_path = local_file_path:gsub(fs, mapping.remote)

      if mapping.rewrite then
        local rewrite_result = mapping.rewrite({
          fs = local_file_path,
          remote = server_path,
          extension = vim.fn.fnamemodify(local_file_path, ":e"),
        })

        if rewrite_result then
          server_path = rewrite_result
        else
          server_path = nil
        end
      end

      break
    end
  end

  return server_path
end

M.pick_host = nio.wrap(function(cb)
  local hosts = vim.deepcopy(config.options.hosts)

  table.insert(hosts, 1, { label = "Other", host = "CUSTOM-HOST" })

  -- We have to use vim.ui.select because noice.nvim does not support select
  -- created with nio.ui.select
  vim.ui.select(hosts, {
    prompt = "Select host:",
    format_item = function(item)
      return item.label .. " (" .. item.host .. ")"
    end,
  }, function(choice)
    if not choice then
      vim.notify("No host selected", vim.log.levels.WARN, {
        title = "Deploy",
      })

      return cb(nil)
    end

    if choice.host == "CUSTOM-HOST" then
      local custom_host = vim.fn.input("Enter custom host: ")

      if custom_host == "" then
        vim.notify("No custom host provided", vim.log.levels.WARN, {
          title = "Deploy",
        })
        return cb(nil)
      end

      choice.host = custom_host
    end

    cb(choice)
  end)
end, 1)

M.test = nio.create(function()
  local host = M.pick_host()

  print(vim.inspect(host))
end)

return M
