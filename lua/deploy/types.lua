
---@meta DeployTypes

---@class RewriteFunctionContext
---@field fs string Local filesystem path.
---@field remote string Remote path.
---@field file_extension string The file extension, if applicable. If no file extension is present, this will be an empty string.

---@alias RewriteFunction fun(context: RewriteFunctionContext): string | false

---@class DeployHost
---@field host string The host to which we can deploy.
---@field label string A label for the host.
---@field rewrite? RewriteFunction An optional function to rewrite the remote path before deployment.

---@class DeployMapping
---@field fs string Local filesystem path.
---@field remote string Remote path.
---@field rewrite? RewriteFunction An optional function to rewrite the remote path before deployment.

---@class DeployConfig
---@field timeout? number The timeout for deployment (Seconds). Default is 3.
---@field hosts DeployHost[] A table of hosts to which we can deploy.
---@field mapping DeployMapping[] A table of mappings from local filesystem paths to remote paths.

---@class Subcommand
---@field impl fun(args:string[], opts: table) The command implementation
---@field complete? fun(subcmd_arg_lead: string): string[] (optional) Command completions callback, taking the lead of the subcommand's arguments
