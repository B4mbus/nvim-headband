---@module nvim-headband
---@author Daniel Zaradny <danielzaradny@gmail.com>
---@license MIT

local has_winbar = function()
  return vim.api.nvim_get_all_options_info()['winbar']
end

local issue_lack_of_winbar_notification = function()
  require 'nvim-headband.error_handler'.headband_notify_error_deffered(
    'This neovim installation does not have the winbar feature. Cannot enable nvim-headband.'
  )
end

local issue_setup_error_notification = function(error)
  local ErrorHandler = require 'nvim-headband.impl.error_handler'

  ErrorHandler.headband_notify_error_deffered(
    'Error encountered while trying to setup the winbar, disabling.\n'
    .. 'Make sure your config is correct.'
    .. 'If you are sure it\'s a bug, please file an issue on "https://github.com/B4mbus/nvim-headband".'
    .. '\n\n'
    .. error
  )
end

local Headband = {}

Headband.protected_setup = function(config)
  require 'nvim-headband.impl.highlights'.setup_highlights(config.highlights)
  require 'nvim-headband.impl.winbar'.start(config)
end

--- Function to call to get winbar up and running
Headband.setup = function(user_config)
  if not has_winbar() then
    issue_lack_of_winbar_notification()
  else
    local default_config = require 'nvim-headband.default_config'
    local config = vim.tbl_deep_extend('force', default_config, user_config or {})

    if not config.enable then
      return
    end

    xpcall(Headband.protected_setup, issue_setup_error_notification, config)
  end
end

--- Enables the headband winbar
Headband.enable = function()
  NvimHeadbandWinbarMod:enable()
end

--- Disables the headband winbar
Headband.disable = function()
  NvimHeadbandWinbarMod:disable()
end

--- Enables the headband winbar if it's disabled and disables it if it's enabled
Headband.toggle = function()
  if NvimHeadbandWinbarMod.config.enable then
    NvimHeadbandWinbarMod:disable()
  else
    NvimHeadbandWinbarMod:enable()
  end
end

return Headband
