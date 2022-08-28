local issue_lack_of_location_provider_error = function()
  require 'nvim-headband.impl.error_handler'.headband_notify_error_deffered(
    'The "SmiteshP/nvim-navic" plugin is not present. Cannot enable navic for winbar.'
  )
end

local get_location_provider_mod = function()
  local conditional_require = require 'nvim-headband.impl.utils'.conditional_require

   return conditional_require('nvim-navic', issue_lack_of_location_provider_error)
end

local get_location_icons = function(config)
  if type(config.icons) == 'string' and config.icons == 'default' then
    return {
      File          = " ",
      Module        = " ",
      Namespace     = " ",
      Package       = " ",
      Class         = " ",
      Method        = " ",
      Property      = " ",
      Field         = " ",
      Constructor   = " ",
      Enum          = "練",
      Interface     = "練",
      Function      = " ",
      Variable      = " ",
      Constant      = " ",
      String        = " ",
      Number        = " ",
      Boolean       = "◩ ",
      Array         = " ",
      Object        = " ",
      Key           = " ",
      Null          = "ﳠ ",
      EnumMember    = " ",
      Struct        = " ",
      Event         = " ",
      Operator      = " ",
      TypeParameter = " ",
    }
  elseif type(config.icons) == 'table' then
    return config.icons
  else
    error('The type of the "config.location_section.icons" option has to be a string or a table.')
  end
end

local setup_location_provider = function(config)
  local loaded, location_provider = get_location_provider_mod()

  if loaded then
    location_provider.setup {
      icons = get_location_icons(config),
      highlight = (config.highlights.location_icons ~= 'none'),

      separator = ' ' .. config.separator .. ' ',
      depth_limit = config.depth_limit,
      depth_limit_indicator = config.depth_limit_indicator,
    }
  end
end

local LocationSection = {}

function LocationSection:get_empty_symbol()
  local empty_symbol = self.config.empty_symbol
  local hl = require 'nvim-headband.impl.utils'.hl

  if empty_symbol == '' then
    return ''
  else
    return
      hl('NvimHeadbandEmptyLocSymbol')
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

  if not config.enable then
    return false, ''
  end

  setup_location_provider(config)

  self.config = config

  local loc_provider_loaded, loc_provider = get_location_provider_mod()
  -- TODO: maybe abstract away?
  local available = loc_provider.is_available()

  if loc_provider_loaded then
    local wrapper = require 'nvim-headband.impl.winbar.shared'.evaluate_wrap(self.config.wrap)
    local location_string = wrapper(self:get_location(loc_provider))

    return available, (available and location_string or '')
  end
end

return LocationSection
