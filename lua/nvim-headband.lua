---@module nvim-headband
---@author Daniel Zaradny <danielzaradny@gmail.com>
---@license MIT

local ErrorHandler = require('nvim-headband.impl.error_handler')

local function has_winbar()
  return vim.api.nvim_get_all_options_info()['winbar']
end

local function issue_lack_of_winbar_notification()
  ErrorHandler.headband_notify_error_deffered(
    'This neovim installation does not have the winbar feature. Cannot enable nvim-headband.'
  )
end

local function issue_setup_error_notification(error)
  ErrorHandler.headband_notify_error_deffered(
    'Error encountered while trying to setup the winbar, disabling.\n'
      .. 'Make sure your config is correct.\n'
      .. 'If you are sure it\'s a bug, please file an issue on "https://github.com/B4mbus/nvim-headband".'
      .. '\n\n'
      .. error
  )
end

local Headband = {}

function Headband.protected_setup(config)
  require('nvim-headband.impl.highlights').setup_highlights(config.styling)
  require('nvim-headband.impl.winbar').start(config)
end

--- Function to call to get winbar up and running
---@param user_config UserConfig? The user configuration table to use
function Headband.setup(user_config)
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
function Headband.enable()
  NvimHeadbandWinbarMod:enable()
end

--- Disables the headband winbar
function Headband.disable()
  NvimHeadbandWinbarMod:disable()
end

--- Enables the headband winbar if it's disabled and disables it if it's enabled
function Headband.toggle()
  if NvimHeadbandWinbarMod.config.enable then
    NvimHeadbandWinbarMod:disable()
  else
    NvimHeadbandWinbarMod:enable()
  end
end

return Headband
