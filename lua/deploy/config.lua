local M = {}

--@class DeployConfig
M.defaults = {
  tool = "rsync",
  honor_gitignore = true,
  --@type table<number, {fs: string, remote: string}>
  mapping = {
    {
      fs = "/home/patrik/develop/repos/mis/sw/ims/ims4/Web/src/main/webapp",
      remote = "/opt/ims/tomcat/webapps/ims",
    },
  },
  filter = {},
}

M.options = {}

--@param opts DeployConfig
M.setup = function(opts)
  vim.g.DEPLOY_LAST_HOST = vim.g.DEPLOY_LAST_HOST or "0.0.0.0"
  vim.g.DEPLOY_ON_SAVE = vim.g.DEPLOY_ON_SAVE or false

  --@type DeployConfig
  M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

return M
