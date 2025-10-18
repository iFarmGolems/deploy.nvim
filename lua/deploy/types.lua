
---@meta DeployTypes

---@class RewriteFunctionContext
---@field local_path string Local filesystem path.
---@field remote_path string Remote path.
---@field file_extension string | nil The file extension of the local file, or nil if it has none.

---@alias RewriteFunction fun(context: RewriteFunctionContext): string | false | nil

---@class DeployHost
---@field host string The host to which we can deploy.
---@field label string A label for the host.
---@field rewrite? RewriteFunction An optional function to rewrite the remote path before deployment.

---@class DeployMapping
---@field fs string Local filesystem folder.
---@field remote string Remote folder.
---@field rewrite? RewriteFunction An optional function to rewrite the server path before deployment.

---@class DeployConfig
---@field timeout number The timeout for deployment (Seconds). Default is 3.
---@field hosts DeployHost[] A table of hosts to which we can deploy.
---@field mapping DeployMapping[] A table of mappings from local filesystem paths to remote paths.

---@class Subcommand
---@field impl fun(args:string[], opts: table) The command implementation
---@field complete? fun(subcmd_arg_lead: string): string[] (optional) Command completions callback, taking the lead of the subcommand's arguments
