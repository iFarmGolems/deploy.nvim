local nio = require("nio")
local config = require("deploy.config")

local M = {}

M.pick_host = nio.wrap(function(cb)
  local hosts = vim.deepcopy(config.options.hosts)

  table.insert(hosts, 1, { label = "Other", host = "CUSTOM_HOST" })

  -- We have to use vim.ui.select because noice does not support select created
  -- with nio.ui.select
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

    if choice.host == "CUSTOM_HOST" then
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
  vim.notify("Hello from lib2.lua", vim.log.levels.INFO, {
    title = "Deploy Test",
  })

  local host = M.pick_host()

  print(vim.inspect(host))
end)

return M
