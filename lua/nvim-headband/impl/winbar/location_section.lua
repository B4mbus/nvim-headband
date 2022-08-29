local hl = require('nvim-headband.impl.utils').hl
local empty_hl = require('nvim-headband.impl.utils').empty_hl

local function issue_lack_of_location_provider_error()
  require('nvim-headband.impl.error_handler').headband_notify_error_deffered(
    'The "SmiteshP/nvim-navic" plugin is not present. Cannot enable navic for winbar.'
  )
end

local function get_location_provider_mod()
  local conditional_require = require('nvim-headband.impl.utils').conditional_require

  return conditional_require('nvim-navic', issue_lack_of_location_provider_error)
end

local function get_location_icons(config)
  if type(config.icons) == 'string' and config.icons == 'default' then
    return {
      File = ' ',
      Module = ' ',
      Namespace = ' ',
      Package = ' ',
      Class = ' ',
      Method = ' ',
      Property = ' ',
      Field = ' ',
      Constructor = ' ',
      Enum = '練',
      Interface = '練',
      Function = ' ',
      Variable = ' ',
      Constant = ' ',
      String = ' ',
      Number = ' ',
      Boolean = '◩ ',
      Array = ' ',
      Object = ' ',
      Key = ' ',
      Null = 'ﳠ ',
      EnumMember = ' ',
      Struct = ' ',
      Event = ' ',
      Operator = ' ',
      TypeParameter = ' ',
    }
  elseif type(config.icons) == 'table' then
    return config.icons
  else
    error 'The type of the "config.location_section.icons" option has to be a string or a table.'
  end
end

local function get_raw_locations_items(data, reverse)
  if not data then
    return nil
  end

  local icon_hl = function(name, icon)
    return hl('NavicIcons' .. name) .. icon .. empty_hl
  end

  return vim.tbl_map(
    function(item)
      if reverse then
        return icon_hl(item.type, item.icon) .. item.name
      else
        return item.name .. icon_hl(item.type, item.icon)
      end
    end,
    data
  )
end

local LocationSection = {}


function LocationSection:setup_location_provider(location_provider)
  location_provider.setup {
    icons = get_location_icons(self.config),
    highlight = (self.config.highlights.location_icons ~= 'none'),

    depth_limit = self.config.depth_limit,
    depth_limit_indicator = self.config.depth_limit_indicator,
  }
end


function LocationSection:get_empty_symbol()
  return hl 'NvimHeadbandEmptyLocSymbol' .. self.conig.empty_symbol .. empty_hl
end

function LocationSection:get_location(mod)
  local raw_location_items = get_raw_locations_items(mod.get_data())

  if not raw_location_items then
    if self.config.empty_symbol ~= '' then
      return self:get_empty_symbol()
    else
      return ''
    end
  end

  local build_separator = function(sep)
    return ' ' .. hl 'NavicSeparator' .. sep .. empty_hl .. ' '
  end

  local separator = build_separator(self.config.separator)

  return table.concat(raw_location_items, separator)
end

function LocationSection.get(config)
  local self = LocationSection

  if not config.enable then
    return false, ''
  end

  local loc_provider_loaded, loc_provider = get_location_provider_mod()
  if loc_provider_loaded then
    self.config = config

    if not self.location_setup then
      self:setup_location_provider(loc_provider_loaded, loc_provider)
      self.location_setup = true
    end

    self.config = config

    local available = loc_provider.is_available()

    local wrapper = require 'nvim-headband.impl.winbar.shared'.evaluate_wrap(self.config.wrap)
    local location = wrapper(self:get_location(loc_provider))

    return available, (available and location or '')
  end
end

return LocationSection
