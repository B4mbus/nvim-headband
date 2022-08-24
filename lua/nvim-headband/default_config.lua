local symbols = require 'nvim-headband.symbols'

---@class UserConfig
---@field public enable boolean Whether to enable the winbar
---@field public general_separator string Separator between the file section and navic section, if both are present, can be disabled by setting it to ''
---@field public empty_buffer_text string The text to display when an empty buffer is opened
---@field public file_section UserConfig.FileSection Configuration for the file section of the winbar
---@field public navic_section UserConfig.NavicSection Configuration for the navic section of the winbar
local default_config = {
  enable = true,
  general_separator = '::',
  empty_buffer = '[No name]',

  ---@class UserConfig.FileSection
  ---@field public enable boolean Whether to enable or disable the file section
  ---@field public style string Style of the file section can be 'filename' | 'shortened' | 'full'
  ---@field public bold_filename boolean Whether set the NvimHeadbandFilename hl group as bold
  ---@field public devicons UserConfig.File.DevIcons Configuration for the file section's devicons
  file_section = {
    enable = true,
    style = 'filename',
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
