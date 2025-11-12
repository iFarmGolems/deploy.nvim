---@meta DeployTypes

---@class DeployContext
---@field source string Local source file path
---@field destination string Remote destination file path
---@field address string The host address to which we are deploying

---@class DeployOptions
---@field silent? boolean Whether to suppress output messages
---@field deploy_to_last_host? boolean Whether to deploy to the last used host without prompting

---@class RewriteFunctionContext : DeployContext
---@field extension? string (Optional) The file extension of the source file

---@alias RewriteFunction fun(context: RewriteFunctionContext): false|nil

---@class ShellCommandResult
---@field code number The exit code of the command.
---@field out string The standard output or error output of the command.
---@field command string The full command that was executed.

---@class DeployHost
---@field address string The host address to which we can deploy.
---@field label string A label for the host.
---@field rewrite? RewriteFunction An optional function to rewrite the remote path before deployment.

---@class DeployMapping
---@field fs string Local filesystem folder.
---@field remote string Remote folder.
---@field rewrite? RewriteFunction An optional function to rewrite the server path before deployment.

---@class DeployConfig
---@field timeout number The timeout for deployment (Seconds). Default is 3.
---@field hosts DeployHost[] A table of hosts to which we can deploy.
---@field mappings DeployMapping[] A table of mappings from local filesystem paths to remote paths.

---@class Subcommand
---@field impl fun(args:string[], opts: table) The command implementation
---@field complete? fun(subcmd_arg_lead: string): string[] (optional) Command completions callback, taking the lead of the subcommand's arguments
