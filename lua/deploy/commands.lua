local M = {}

M.get_current_win = function()
  local win = vim.api.nvim_get_current_win()
  return win
end

M.get_current_file_path = function()
  local current_buf = vim.api.nvim_get_current_buf()
  return vim.api.nvim_buf_get_name(current_buf)
end

M.deploy_current_file = function()
  local file_path = M.get_current_file_path()
end

M.can_be_deployed = function()
  local file_path = M.get_current_file_path()
  return file_path:match(".+%.lua$")
end

return M
