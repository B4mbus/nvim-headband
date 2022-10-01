if exists('g:nvim_headband_loaded')
  finish
endif
let g:nvim_headband_loaded = 1

lua require('nvim-headband').setup()
