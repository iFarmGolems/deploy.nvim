local config = require("deploy.config")
require("deploy.commands")

local M = {}

M.setup = config.setup

return M
