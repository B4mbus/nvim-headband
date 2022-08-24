return {
  issue_headband_error = function(content)
    vim.notify_once(
        content,
        vim.log.levels.ERROR,
        {
          title = 'Nvim-headband',
        }
    )
  end
}
