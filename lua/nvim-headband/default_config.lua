local symbols = require('nvim-headband.symbols')

local strict_combine = require('nvim-headband.filters').strict_combine
local bt_filter = require('nvim-headband.filters').bt_filter
local ft_filter = require('nvim-headband.filters').ft_filter

--- Takes a buffer id, buffer name, buffertype and a filetype and returns a string, used in places like separator_text, unsaved_buffer_text or file_section.text
---@alias StringFunc fun(bid: number, bname: string, bt: string, ft: string): string

--- Basically asks a question 'should this window be excluded from having a winbar?', that is, if it returns true, a window will not have a winbar
---@alias FilterFunc fun(bname: string, bt: string, ft: string, prev: boolean): boolean

--- Returns two string values that will wrap a section
---@alias WrapFunc fun(): string, string

--- The position of a section, a string, either a 'left' or 'right'
---@alias SectionPosition 'left' | 'right'

--- The user configuration that's meant to be passed to setup()
---@class UserConfig
---@field public enable boolean Whether to enable the headband winbar
---@field public separator_text string | StringFunc A string that will be displayed as separator between the file and location section, if both are present (can be a StringFunc)
---@field public unsaved_buffer_text string | StringFunc A string that will be displayed when an unsaved buffer is opened (can be a StringFunc)
---@field window_filter FilterFunc Filters out windows that should not have a winbar, e.g. trees, dashboards, neogit
---
---@field public file_section UserConfig.FileSection The file section config
---@field public location_section UserConfig.LocationSection The location section config
---@field public styling UserConfig.Styling Highlights and other styling config
local default_config = {
  enable = true,
  separator_text = '::',
  unsaved_buffer_text = '%f',

  window_filter = strict_combine(
    bt_filter {
      'NvimTree',
      'nerdtree',
      'neo-tree',
      'packer',
      'alpha',
      'dashboard',
      'startify',
      'nofile',
    },
    ft_filter {
      'NeogitCommitMessage',
    }
  ),

  ---@class UserConfig.FileSection
  ---@field public enable boolean Whether to enable the file section
  ---@field public text string | StringFunc The text of the file section, can be 'filename' | 'full' | 'shortened' | 'full_lower' | 'shortened_lower' or a StringFunc
  ---@field public wrap string[] | WrapFunc | nil Wraps the section in some strings
  ---@field public enable_devicons boolean Whether to enable devicons for the file section
  ---@field public position SectionPosition The position of the section
  ---@field public reversed boolean Whether the path should be reversed
  file_section = {
    enable = true,

    text = 'filename',

    wrap = nil,

    enable_devicons = true,

    position = 'left',
    reversed = false,
  },

  ---@class UserConfig.LocationSection
  ---@field public enable boolean Whether to enable the location section
  ---@field public depth_limit number The maximum number of location elements to be shown, 0 means infinite
  ---@field public depth_limit_indicator string A string to show when the depth_limit is reached
  ---@field public wrap string[] | WrapFunc | nil Wraps the section in some strings
  ---@field public empty_symbol string | nil A symbol to show when location is available but there's no context to show (e.g. global namespace)
  ---@field public icons string | table The icons to use, can be set to 'none' to disable, 'default' to register default and a table for custom ones
  ---@field public position SectionPosition The position of the section
  ---@field public reversed boolean Whether the path should be reversed
  location_section = {
    enable = true,

    depth_limit = 0,
    depth_limit_indicator = symbols.ellipsis,

    wrap = nil,

    empty_symbol = symbols.empty_set,

    separator = symbols.nice_arrow,

    icons = 'default',

    position = 'left',
    reversed = false,
  },

  ---@class UserConfig.Styling
  ---@field public highlights UserConfig.Styling.Highlights Highlighting options
  ---@field public bold_filename boolean Whether to set the NvimHeadbandFilename group to bold by default
  styling = {
    ---@class UserConfig.Styling.Highlights Highlighting options
    ---@field public devicons boolean Whether to highlight devicons
    ---@field public default_location_separator boolean Whether to highlight the location separator by default
    ---@field public location_icons string Can be 'link' | 'default' | 'none', if set to 'link' it will link to CmpItme* highlight groups, if set to default, it will set the default vscodey'y hl groups, if set to 'none', it will set none
    highlights = {
      devicons = true,
      default_location_separator = true,
      location_icons = 'link',
    },
    bold_filename = true,
  },
}

return default_config
