
---@meta DeployTypes

---@alias Tool 'rsync' | 'sftp'
---@alias RewriteFunction fun(server_path: string, fs_path: string): string

---@class DeployHost
---@field host string The host to which we can deploy.
---@field label string A label for the host.
---@field rewrite? RewriteFunction An optional function to rewrite the server path before deployment.

---@class DeployMapping
---@field fs string Local filesystem folder.
---@field remote string Remote folder.

---@class DeployConfig
---@field tool Tool The tool to use for deployment. Default is "rsync".
---@field honor_gitignore boolean Whether to respect .gitignore files when deploying. Default is true.
---@field hosts DeployHost[] A table of hosts to which we can deploy.
---@field mapping DeployMapping[] A table of mappings from local filesystem paths to remote paths.

---@class Subcommand
---@field impl fun(args:string[], opts: table) The command implementation
---@field complete? fun(subcmd_arg_lead: string): string[] (optional) Command completions callback, taking the lead of the subcommand's arguments
