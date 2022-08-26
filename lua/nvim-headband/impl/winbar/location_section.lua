local LocationSection = {}

local issue_lack_of_navic_error = function()
  require 'nvim-headband.impl.error_handler'.headband_notify_error_deffered(
    'The "SmiteshP/nvim-navic" plugin is not present. Cannot enable navic for winbar.'
  )
end

local get_navic_mod = function()
  local conditional_require = require 'nvim-headband.impl.conditional_require'

   return conditional_require('nvim-navic', issue_lack_of_navic_error)
end

local hl = function(group)
  return '%#' .. group .. '#'
end

function LocationSection:get_navic_hl()
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
      self:get_navic_hl()
      .. empty_symbol
  end
end

function LocationSection:get_navic_location(navic)
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

  local navic_loaded, navic = get_navic_mod()
  local available = navic.is_available()

  if navic_loaded then
    return available, (available and self:get_navic_location(navic) or '')
  end
end

return LocationSection
