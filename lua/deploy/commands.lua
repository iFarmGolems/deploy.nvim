local lib = require("deploy.lib")
local lib2 = require("deploy.lib2")

---@type table<string, Subcommand>
local subcommand_tbl = {
  file = {
    impl = function(args, opts)
      lib.deploy_file(vim.fn.expand("%:p"))
      -- Implementation (args is a list of strings)
    end,
    -- This subcommand has no completions
  },
  toggle = {
    impl = function()
      lib.toggle_deploy_on_save()
    end,
  },
  test = {
    impl = function()
      lib2.test()
    end,
  },
  compare = {
    impl = function()
      lib.compare_with_remote_file()
    end,
  },
  test = {
    impl = function()
      lib.test()
    end,
  },
  -- install = {
  --   impl = function(args, opts)
  --     -- Implementation
  --   end,
  --   complete = function(subcmd_arg_lead)
  --     -- Simplified example
  --     local install_args = {
  --       "neorg",
  --       "rest.nvim",
  --       "rustaceanvim",
  --     }
  --     return vim
  --       .iter(install_args)
  --       :filter(function(install_arg)
  --         -- If the user has typed `:Rocks install ne`,
  --         -- this will match 'neorg'
  --         return install_arg:find(subcmd_arg_lead) ~= nil
  --       end)
  --       :totable()
  --   end,
  --   -- ...
  -- },
}

---@param opts table :h lua-guide-commands-create
local function my_cmd(opts)
  local fargs = opts.fargs
  local subcommand_key = fargs[1]
  -- Get the subcommand's arguments, if any
  local args = #fargs > 1 and vim.list_slice(fargs, 2, #fargs) or {}
  local subcommand = subcommand_tbl[subcommand_key]
  if not subcommand then
    vim.notify("Rocks: Unknown command: " .. subcommand_key, vim.log.levels.ERROR)
    return
  end
  -- Invoke the subcommand
  subcommand.impl(args, opts)
end

vim.api.nvim_create_user_command("Deploy", my_cmd, {
  nargs = "+",
  desc = "My awesome command with subcommand completions",
  complete = function(arg_lead, cmdline, _)
    -- Get the subcommand.
    local subcmd_key, subcmd_arg_lead = cmdline:match("^Deploy[!]*%s(%S+)%s(.*)$")
    if subcmd_key and subcmd_arg_lead and subcommand_tbl[subcmd_key] and subcommand_tbl[subcmd_key].complete then
      -- The subcommand has completions. Return them.
      return subcommand_tbl[subcmd_key].complete(subcmd_arg_lead)
    end
    -- Check if cmdline is a subcommand
    if cmdline:match("^Deploy[!]*%s+%w*$") then
      -- Filter subcommands that match
      local subcommand_keys = vim.tbl_keys(subcommand_tbl)
      return vim
        .iter(subcommand_keys)
        :filter(function(key)
          return key:find(arg_lead) ~= nil
        end)
        :totable()
    end
  end,
  bang = true, -- If you want to support ! modifiers
})

vim.api.nvim_create_autocmd("BufWritePost", {
  callback = function(opts)
    if vim.g.DEPLOY_ON_SAVE then
      lib.auto_deploy_file(opts.match)
    end
  end,
})
