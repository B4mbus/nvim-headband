local M = {}

--- Notifies the user about the error
---@param content string The content of the error message
M.issue_headband_error = function(content)
  vim.notify_once(
    content,
    vim.log.levels.ERROR,
    {
      title = 'nvim-headband',
    }
  )
end

return M
