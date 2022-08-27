local symbols = require 'nvim-headband.symbols'
require 'nvim-headband.impl.config_annotations' -- not sure if I have to require this lol

local strict_combine = require 'nvim-headband.filters'.strict_combine
local bt_filter = require 'nvim-headband.filters'.bt_filter
local ft_filter = require 'nvim-headband.filters'.ft_filter

---@type UserConfig
local default_config = {
  enable = true,
  general_separator = '::',
  unsaved_buffer_text = '[No name]',
  window_filter = strict_combine(
    bt_filter {
      'NvimTree',
      'nerdtree',
      'neot-tree',
      'packer',
      'alpha',
      'dashboard',
      'startify',
      'nofile'
    },
    ft_filter {
      'NeogitCommitMessage'
    }
  ),

  ---@type UserConfig.FileSection
  file_section = {
    enable = true,

    text = 'filename',
    bold_filename = true,

    wrap = nil,

    ---@type UserConfig.FileSection.DevIcons
    devicons = {
      enable = true,
      highlight = true
    },
  },

  ---@type UserConfig.LocationSection
  location_section = {
    enable = true,

    depth_limit = 0,
    depth_limit_indicator = symbols.ellipsis,

    wrap = nil,

    ---@type UserConfig.LocationSection.EmptySymbol
    empty_symbol = {
      symbol = symbols.empty_set,
      highlight = true
    },

    ---@type UserConfig.LocationSection.Separator
    separator = {
      symbol = symbols.nice_arrow,
      highlight = true
    },

    ---@type UserConfig.LocationSection.Icons
    icons = {
      default_icons = true,
      highlights = 'link'
    }
  }
}

return default_config
