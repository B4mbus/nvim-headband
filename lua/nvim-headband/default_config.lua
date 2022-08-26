local symbols = require 'nvim-headband.symbols'

---A function for handling buffers, called inside multiple places from headband
---@alias BufferFunc fun(bid: number, bname: string, bt: string, ft: string): boolean

---@class UserConfig
---@field public enable boolean Whether to enable the winbar
---@field public general_separator string Separator between the file section and navic section, if both are present, can be disabled by setting it to ''
---@field public unsaved_buffer_text string | BufferFunc The text to display for an unsaved buffer, can be @BufferFunc
---@field public buffer_filter BufferFunc A function that filters buffers out (buffers for which it will return false won't have winbar enabled)
---@field public file_section UserConfig.FileSection Configuration for the file section of the winbar
---@field public navic_section UserConfig.NavicSection Configuration for the navic section of the winbar
local default_config = {
  enable = true,
  general_separator = '::',
  unsaved_buffer_text = '[No name]',
  buffer_filter = require 'nvim-headband.utils'.bt_filter {
    'NvimTree',
  },

  ---@class UserConfig.FileSection
  ---@field public enable boolean Whether to enable or disable the file section
  ---@field public text string | BufferFunc Style of the file section can be 'filename' | 'shortened' | 'shortened_lower' | 'full' | 'full_lower or a @BufferFunc that will return the text
  ---@field public bold_filename boolean Whether set the NvimHeadbandFilename hl group as bold
  ---@field public devicons UserConfig.File.DevIcons Configuration for the file section's devicons
  file_section = {
    enable = true,
    text = 'filename',
    bold_filename = true,

    ---@class UserConfig.File.DevIcons
    ---@field public enable boolean Whether to enable devicons in front of the filename
    ---@field public highlight boolean Whether to enable devicons highlighting
    devicons = {
      enable = true,
      highlight = true
    },
  },

  ---
  ---@class UserConfig.NavicSection
  ---@field public enable boolean Whether to enable the navic section
  ---@field public depth_limit number The depth limit of the navic symbols, 0 means none
  ---@field public depth_limit_indicator string The depth limit indicator that is used when the limit is reached
  --
  ---@field public empty_symbol UserConfig.Navic.EmptySymbol Configuration for the empty navic symbol
  ---@field public separator UserConfig.Navic.Separator Configuration for the separator between the navic elements
  ---@field public icons UserConfig.Navic.Icons Configuration for navic icons
  navic_section = {
    enable = true,

    depth_limit = 0,
    depth_limit_indicator = symbols.ellipsis,

    ---@class UserConfig.Navic.EmptySymbol
    ---@field public symbol string The symbol that will be displayed when navic is available but the location is empty, can be disabled by setting it to ''
    ---@field public highlight boolean Whether to highlight the empty location symbol
    empty_symbol = {
      symbol = symbols.empty_set,
      highlight = true
    },

    ---@class UserConfig.Navic.Separator
    ---@field public symbol string The symbol to use for a navic separator
    ---@field public highlight boolean Whether to register the default highlight group for the separator
    separator = {
      symbol = symbols.nice_arrow,
      highlight = true
    },

    ---@class UserConfig.Navic.Icons
    ---@field public default_icons boolean Whether to enable the default navic icons
    ---@field public highlights string How to highlight the default navic groups, the valid options are 'none' | 'link'| 'default'
    icons = {
      default_icons = true,
      highlights = 'link'
    },
  }
}

return default_config
