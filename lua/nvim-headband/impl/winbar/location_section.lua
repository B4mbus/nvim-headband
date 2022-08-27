local LocationSection = {}

local issue_lack_of_location_provider_error = function()
  require 'nvim-headband.impl.error_handler'.headband_notify_error_deffered(
    'The "SmiteshP/nvim-navic" plugin is not present. Cannot enable navic for winbar.'
  )
end

local get_location_provider_mod = function()
  local conditional_require = require 'nvim-headband.impl.utils'.conditional_require

   return conditional_require('nvim-navic', issue_lack_of_location_provider_error)
end

local hl = function(group)
  return '%#' .. group .. '#'
end

function LocationSection:get_loc_empty_hl()
  if self.config.empty_symbol.highlight then
    return hl('NvimHeadbandEmptyLoc')
  else
    return ''
  end
end

function LocationSection:get_empty_symbol()
  local empty_symbol = self.config.empty_symbol.symbol

  if empty_symbol == '' then
    return ''
  else
    return
      self:get_loc_empty_hl()
      .. empty_symbol
  end
end

function LocationSection:get_location(navic)
  local loc = navic.get_location()

  if loc == '' then
    return self:get_empty_symbol()
  else
    return loc
  end
end

function LocationSection.get(config)
  local self = LocationSection

  self.config = config

  if not self.config.enable then
    return false, ''
  end

  local loc_provider_loaded, loc_provider = get_location_provider_mod()
  -- TODO: maybe abstract away?
  local available = loc_provider.is_available()

  if loc_provider_loaded then
    local wrapper = require 'nvim-headband.impl.winbar.shared'.evaluate_wrap()
    local location_string = wrapper(self:get_location(loc_provider))

    return available, (available and location_string or '')
  end
end

return LocationSection
