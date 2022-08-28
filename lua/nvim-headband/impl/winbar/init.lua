local api = vim.api
local fn = vim.fn

local hl = require 'nvim-headband.impl.utils'.hl
local empty_hl = require 'nvim-headband.impl.utils'.empty_hl

local ErrorHandler = require 'nvim-headband.impl.error_handler'

local get_headband_callback = function(mod)
  return function()
    local proper_buffer =
      api.nvim_buf_get_option(0, 'buftype') == ''
      and fn.getcmdwintype() == ''

    if proper_buffer then
      vim.wo.winbar = mod.winbar_string
    end
  end
end

local patch_highlight_config = function(config)
  config.file_section.highlights = {}
  config.file_section.highlights.devicons = config.highlights.devicons

  config.location_section.highlights = {}
  config.location_section.highlights.location_icons = config.highlights.location_icons

  return config
end

--- The global winbar mod, contains the whole needed state for the winbar to work
NvimHeadbandWinbarMod = {}

function NvimHeadbandWinbarMod:separator_available(loc_available)
  return
    self.config.file_section.enable
    and self.config.location_section.enable
    and loc_available
end

function NvimHeadbandWinbarMod:get_separator_conditionally(loc_available)
  if not self:separator_available(loc_available) then
    return ''
  end

  local call_or_id = require 'nvim-headband.impl.utils'.call_or_id

  return
    hl('NvimHeadbandSeparator')
    .. ' '
    .. call_or_id(self.config.separator_text)
    .. ' '
    .. empty_hl
end

function NvimHeadbandWinbarMod.get_winbar(self)
  local file_readable = fn.filereadable(fn.expand('%:p')) ~= 0

  if not file_readable then
    local ubt = self.config.unsaved_buffer_text
    local call_or_id = require 'nvim-headband.impl.utils'.call_or_id

    return hl('NvimHeadbandEmptyBuf') .. ' ' .. call_or_id(ubt)
  end

  -- HACK: hacky as b4LLz, but fuck it, no one's gonna see :tf:
  self.config = patch_highlight_config(self.config)

  local loc_section_mod = require 'nvim-headband.impl.winbar.location_section'
  local loc_available, loc_section = loc_section_mod.get(self.config.location_section)

  local file_section_mod = require 'nvim-headband.impl.winbar.file_section'

  return
    hl('WinBar')
    .. ' '
    .. file_section_mod.get(self.config.file_section)
    .. self:get_separator_conditionally(loc_available and (loc_section ~= ''))
    .. loc_section
end

function NvimHeadbandWinbarMod.get()
  local self = NvimHeadbandWinbarMod

  if not self.config.enable then
    return ''
  end

  local bid = fn.bufwinnr(fn.bufnr())
  local bname = fn.bufname()
  local bt = api.nvim_buf_get_option(0, 'bt')
  local ft = api.nvim_buf_get_option(0, 'ft')

  if self.config.window_filter(bid, bname, bt, ft) then
    self:disable()
    return
  else
    self:enable()
  end

  local error_handler = function(error)
    ErrorHandler.headband_notify_error_deffered(
      'Error encountered while trying to get the winbar, disabling.\n'
      .. 'Make sure your config is correct.'
      .. 'If you are sure it\'s a bug, please file an issue on "https://github.com/B4mbus/nvim-headband".'
      .. '\n\n'
      .. error
    )

    self:disable()
  end

  local _, winbar_string = xpcall(self.get_winbar, error_handler, self)

  return winbar_string
end

function NvimHeadbandWinbarMod:register_autocmd()
  api.nvim_create_autocmd(
    { 'VimEnter', 'BufEnter' },
    {
      pattern = '*',
      group = NvimHeadbandWinbarMod.augroup,
      callback = get_headband_callback(NvimHeadbandWinbarMod)
    }
  )
end

function NvimHeadbandWinbarMod:clear_autocmd()
  api.nvim_clear_autocmds({ group = self.augroup })
end

function NvimHeadbandWinbarMod:soft_enable()
  vim.wo.winbar = self.winbar_string
end

function NvimHeadbandWinbarMod:soft_disable()
  vim.wo.winbar = ''
end

function NvimHeadbandWinbarMod:disable()
  if not self.config.enable then
    return
  end

  self.config.enable = false
  self:clear_autocmd()
  self:soft_disable()
end

function NvimHeadbandWinbarMod:enable(force)
  local force = force or false

  if self.config.enable and not force then
    return
  end

  self.config.enable = true
  self:register_autocmd()
  self:soft_enable()
end

local Winbar = {}

Winbar.start = function(config)
  local augroup = function(x)
    return api.nvim_create_augroup(x, { clear = true })
  end

  NvimHeadbandWinbarMod.config = config
  NvimHeadbandWinbarMod.augroup = augroup('NvimHeadbandWinbar')
  NvimHeadbandWinbarMod.winbar_string = '%{%v:lua.NvimHeadbandWinbarMod.get()%}'

  NvimHeadbandWinbarMod:enable(true)
end

return Winbar
