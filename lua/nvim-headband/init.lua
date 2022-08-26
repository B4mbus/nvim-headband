---@module Nvim-headband
---@author Daniel Zaradny <danielzarany@gmail.com>
---@license MIT

local Headband = {}

local has_winbar = function()
  return vim.api.nvim_get_all_options_info()['winbar']
end

local issue_lack_of_winbar_notification = function()
  local notif = 'nvim-headband.notifications'

  notif.issue_headband_error(
    'This neovim installation does not have the winbar feature. Cannot enable nvim-headband.'
  )
end

--- Function to call to get winbar up and running
---@param user_config UserConfig | nil
Headband.setup = function(user_config)
  if not has_winbar() then
    issue_lack_of_winbar_notification()
  else
    local default_config = require 'nvim-headband.default_config'
    local config = vim.tbl_deep_extend('force', default_config, user_config or {})

    if not config.enable then
      return
    end

    require 'nvim-headband.winbar'.start(config)
  end
end

Headband.enable = function()
  NvimHeadbandWinbarMod:enable()
end

Headband.disable = function()
  NvimHeadbandWinbarMod:disable()
end

Headband.toggle = function()
  if NvimHeadbandWinbarMod.config.enable then
    NvimHeadbandWinbarMod:disable()
  else
    NvimHeadbandWinbarMod:enable()
  end
end

return Headband
