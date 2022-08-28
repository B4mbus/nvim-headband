local hl = require('nvim-headband.impl.utils').hl
local empty_hl = require('nvim-headband.impl.utils').empty_hl

local function issue_lack_of_location_provider_error()
  require('nvim-headband.impl.error_handler').headband_notify_error_deffered 'The "SmiteshP/nvim-navic" plugin is not present. Cannot enable navic for winbar.'
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

local function setup_location_provider(config)
  local loaded, location_provider = get_location_provider_mod()

  if loaded then
    location_provider.setup {
      icons = get_location_icons(config),
      highlight = (config.highlights.location_icons ~= 'none'),

      depth_limit = config.depth_limit,
      depth_limit_indicator = config.depth_limit_indicator,
    }
  end
end

local function get_raw_locations_items(data)
  if not data then
    return nil
  end

  local icon_hl = function(name, icon)
    return hl('NavicIcons' .. name) .. icon .. empty_hl
  end

  return vim.tbl_map(function(item)
    return icon_hl(item.type, item.icon) .. item.name
  end, data)
end

local LocationSection = {}

function LocationSection:get_empty_symbol()
  local empty_symbol = self.config.empty_symbol

  if empty_symbol == '' then
    return ''
  else
    return
hl 'NvimHeadbandEmptyLocSymbol' .. empty_symbol .. empty_hl
  end
end

function LocationSection:get_location(mod)
  local raw_location_items = get_raw_locations_items(mod.get_data())
  if not raw_location_items then
    return self:get_empty_symbol()
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

  setup_location_provider(config)

  self.config = config

  local loc_provider_loaded, loc_provider = get_location_provider_mod()

  local available = loc_provider.is_available()

  if loc_provider_loaded then
    local wrapper = require('nvim-headband.impl.winbar.shared').evaluate_wrap(self.config.wrap)
    local location = wrapper(self:get_location(loc_provider))

    return available, (available and location or '')
  end
end

return LocationSection
