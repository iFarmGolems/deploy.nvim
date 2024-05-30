local M = {}

--@class DeployConfig
M.defaults = {
  -- The tool to use for deployment. Default is "rsync".
  tool = "rsync",

  -- Whether to respect .gitignore files when deploying. Default is true.
  honor_gitignore = true,

  -- A table of hosts to which we can deploy. Each host is a table with a 'host' field (a string)
  -- and a 'label' field (also a string).
  --@type table<number, {host: string, label: string}>
  hosts = {},

  -- A table of mappings from local filesystem paths to remote paths.
  -- Each mapping is a table with a 'fs' field (a string representing a local filesystem path)
  -- and a 'remote' field (a string representing a remote path).
  --@type table<number, {fs: string, remote: string}>
  mapping = {},
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
