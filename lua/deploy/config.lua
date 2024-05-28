vim.g.DEPLOY_LAST_HOST = vim.g.DEPLOY_LAST_HOST or "0.0.0.0"
vim.g.DEPLOY_ON_SAVE = vim.g.DEPLOY_ON_SAVE or false

local M = {}

M.defaults = {
  tool = "rsync",
  mapping = {
    {
      fs = "/home/patrik/develop/repos/mis/sw/ims/ims4/Web/src/main/webapp",
      remote = "/opt/ims/tomcat/webapps/ims",
    },
  },
  filter = {},
}

M.options = {}

M.setup = function(opts)
  M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

return M
