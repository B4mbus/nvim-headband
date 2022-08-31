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
    return nil
  elseif type(config.icons) == 'string' and config.icons == 'none' then
    return  {
      File = '',
      Module = '',
      Namespace = '',
      Package = '',
      Class = '',
      Method = '',
      Property = '',
      Field = '',
      Constructor = '',
      Enum = '',
      Interface = '',
      Function = '',
      Variable = '',
      Constant = '',
      String = '',
      Number = '',
      Boolean = '',
      Array = '',
      Object = '',
      Key = '',
      Null = '',
      EnumMember = '',
      Struct = '',
      Event = '',
      Operator = '',
      TypeParameter = '',
    }
  elseif type(config.icons) == 'table' then
    return config.icons
  else
    error 'The type of the "config.location_section.icons" option has to be a string or a table.'
  end
end

local function get_raw_locations_items(data, reverse)
  if not data or next(data) == nil then
    return nil
  end

  local icon_hl = function(name, icon)
    return (hl('NavicIcons' .. name) .. icon:sub(1, -2) .. empty_hl)
  end

  return vim.tbl_map(
    function(item)
      local empty_icon = item.icon ~= ''

      -- TODO: Refactor maybe? Looks hella unreadable right now.
      if reverse then
        return item.name .. (empty_icon and (' ' .. icon_hl(item.type, item.icon)) or '')
      else
        return (empty_icon and (icon_hl(item.type, item.icon) ..  ' ') or '') .. item.name
      end
    end,
    data
  )
end


local function highlight_empty_symbol(symbol)
  return hl('NvimHeadbandEmptyLocSymbol') .. symbol .. empty_hl
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

function LocationSection:get_location(mod)
  local data = mod.get_data()
  if data and self.config.reversed then
    data = vim.fn.reverse(data)
  end

  local raw_location_items = get_raw_locations_items(data, self.config.reversed)

  if not raw_location_items then
    local symbol = self.config.empty_symbol
    if symbol and symbol ~= '' then
      return highlight_empty_symbol(symbol)
    else
      return ''
    end
  end

  local build_separator = function(sep)
    return ' ' .. hl('NvimHeadbandLocSeparator') .. sep .. empty_hl .. ' '
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
      self:setup_location_provider(loc_provider)
      self.location_setup = true
    end

    self.config = config

    local available = loc_provider.is_available()

    local wrapper = require 'nvim-headband.impl.winbar.shared'.evaluate_wrap(self.config.wrap)
    local location = self:get_location(loc_provider)
    local location_string = (available and location ~= '') and wrapper(location) or ''

    return available, location_string
  end
end

return LocationSection
