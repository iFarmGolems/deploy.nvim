local config = require("deploy.config")
require("deploy.commands")
require("deploy.autocommands")

local M = {}

M.setup = config.setup

return M
