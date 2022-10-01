local color = '#A7C7E7'

vim.api.nvim_set_hl(0, 'NvimHeadbandFilename', { fg = '#000000', bg = color })
vim.api.nvim_set_hl(0, 'NvimHeadbandLocSeparator', { fg = '#6d8086', bg = color })
vim.api.nvim_set_hl(0, 'NvimHeadbandLocText', { fg = '#112233', bg = color })

vim.api.nvim_set_hl(0, 'BubblesFront', { fg = color })

local reverse_arrow = require 'nvim-headband.symbols'.reverse_nice_arrow
local bubbles_wrap = { '%#BubblesFront#', '%#BubblesFront#' }

require 'nvim-headband'.setup {
  file_section = {
    wrap = bubbles_wrap
  },

  location_section = {
    wrap = bubbles_wrap,

    separator = reverse_arrow,

    empty_symbol = '',

    position = 'right',
  }
}
