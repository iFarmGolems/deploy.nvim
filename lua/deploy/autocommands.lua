local lib = require("deploy.lib")

vim.api.nvim_create_autocmd("BufWritePost", {
  callback = function(opts)
    if vim.g.DEPLOY_ON_SAVE then
      local source = opts.match
      lib.deploy_file(source, { silent = true, deploy_to_last_host = true })
    end
  end,
})
