local symbols = require 'nvim-headband.symbols'

local strict_combine = require('nvim-headband.filters').strict_combine
local bt_filter = require('nvim-headband.filters').bt_filter
local ft_filter = require('nvim-headband.filters').ft_filter

local default_config = {
  enable = true,
  separator_text = '::',
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
      'nofile',
    },
    ft_filter {
      'NeogitCommitMessage',
    }
  ),

  file_section = {
    enable = true,

    text = 'filename',

    wrap = nil,

    enable_devicons = true,

    position = 'left',
    reversed = true,
  },

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

  styling = {
    highlights = {
      devicons = true,
      default_location_separator = true,
      location_icons = 'link',
    },
    bold_filename = true,
  },
}

return default_config
