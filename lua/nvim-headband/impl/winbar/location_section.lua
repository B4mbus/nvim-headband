local hl = require('nvim-headband.impl.utils').hl
local empty_hl = require('nvim-headband.impl.utils').empty_hl
local Highlights = require('nvim-headband.impl.highlights')

local function issue_lack_of_location_provider_error()
  local ErrorHandler = require('nvim-headband.impl.error_handler')

  ErrorHandler.headband_notify_error_deffered(
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

local function get_text_highlight()
  return Highlights.highlight_definition('NvimHeadbandLocText')
end

local function create_and_activate_hl_definition(original_name, patched_name, keep_foreground)
  local original_hl_def = Highlights.highlight_definition(original_name)
  local highlight_next_to_icon_bg = get_text_highlight().background

  original_hl_def.background = highlight_next_to_icon_bg

  if not keep_foreground then
    original_hl_def = Highlights.remove_fg_from_definiton(original_hl_def)
  end

  vim.api.nvim_set_hl(0, patched_name, original_hl_def)
end

local function create_local_patched_hl(original_name, keep_foreground)
  local patched_name = 'NvimHeadband' .. original_name .. 'Patched'

  if not Highlights.hl_exists(patched_name) then
    create_and_activate_hl_definition(original_name, patched_name, keep_foreground)
  end

  return patched_name
end

local function hl_name(name)
  return hl('NvimHeadbandLocText') .. name .. empty_hl
end

local function highlight_empty_symbol(symbol)
  return hl('NvimHeadbandEmptyLocSymbol') .. symbol .. empty_hl
end

local build_separator = function(sep)
  return hl('NvimHeadbandLocSeparator') .. ' ' .. sep .. ' ' .. empty_hl
end

local LocationSection = {}

function LocationSection:hl_icon(name, icon)
  --[[
    HACK:
    Hacky asf but nvim navic pads icons with spaces on the left and for some fucking reason
    they are returned with a space from `get_data()`.

    Now the catch is that `Enum` and `Interface` symbols are not padded with a space because they occupy
    2 times the width so simple subbing will basically break things.
  ]]--
  local formatted_icon =
    (name == 'Enum' or name == 'Interface')
      and icon
      or icon:sub(1, -2)

  local highlight_name = 'NavicIcons' .. name

  if Highlights.definition_has_bg(get_text_highlight()) then
    highlight_name = create_local_patched_hl(
      highlight_name,
      not (self.config.highlights.location_icons == 'none') -- if the highlights are not set to none, keep foreground
    )
  end

  return hl(highlight_name) .. formatted_icon .. empty_hl
end

function LocationSection:get_raw_locations_items(data, reverse)
  if not data or next(data) == nil then
    return nil
  end

  return vim.tbl_map(
    function(item)
      local icon_empty = item.icon ~= ''

      -- TODO: Refactor maybe? Looks hella unreadable right now.
      if reverse then
        return hl_name(item.name) .. (icon_empty and self:hl_icon(item.type, ' ' .. item.icon) or '')
      else
        return (icon_empty and self:hl_icon(item.type, item.icon .. ' ') or '') .. hl_name(item.name)
      end
    end,
    data
  )
end

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

  local raw_location_items = self:get_raw_locations_items(data, self.config.reversed)

  if not raw_location_items then
    local symbol = self.config.empty_symbol
    if symbol and symbol ~= '' then
      return highlight_empty_symbol(symbol)
    else
      return ''
    end
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

    local wrapper = require 'nvim-headband.impl.winbar.shared'.create_wrapper(self.config.wrap)
    local location = self:get_location(loc_provider)
    local location_string = (available and location ~= '') and wrapper(location) or ''

    return available, location_string
  end
end

return LocationSection
