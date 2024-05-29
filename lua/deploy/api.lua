local u = require("utils")

local M = {}

M.deploy_current_file = function()
  local file_path = vim.fn.expand("%:p")
  u.deploy_via_rsync(file_path)
end

return M
