local ErrorHandler = {}

--- Issues a notify_once notification with an error, deffered by @timeout milliseconds
---@param content string The error message to display
---@param timeout number | nil The timeout after which the notification should be shown, 100 by default
function ErrorHandler.headband_notify_error_deffered(content, timeout)
  local actual_timeout = timeout or 100

  vim.defer_fn(
    function()
      vim.notify(
        content,
        vim.log.levels.ERROR,
        { title = 'nvim-headband' }
      )
    end,
    actual_timeout
  )
end

return ErrorHandler
