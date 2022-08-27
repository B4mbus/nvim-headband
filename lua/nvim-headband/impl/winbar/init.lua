local api = vim.api
local fn = vim.fn

local hl = require 'nvim-headband.impl.utils'.hl
local empty_hl = require 'nvim-headband.impl.utils'.empty_hl

local ErrorHandler = require 'nvim-headband.impl.error_handler'

--- The global winbar mod, contains the whole needed state for the winbar to work
NvimHeadbandWinbarMod = {}

function NvimHeadbandWinbarMod:separator_available(loc_available)
  return ((self.config.file_section.enable)
    and (self.config.location_section.enable))
    and (loc_available)
end

function NvimHeadbandWinbarMod:get_separator_conditionally(loc_available)
  if not self:separator_available(loc_available) then
    return ''
  end

  return
    hl('NvimHeadbandSeparator')
    .. ' '
    .. self.config.general_separator
    .. ' '
    .. empty_hl
end

function NvimHeadbandWinbarMod.get_winbar(self)
  if not self.config.enable then
    return ''
  end

  local file_readable = fn.filereadable(fn.expand('%:p')) ~= 0
  if not file_readable then
    local ubt = self.config.unsaved_buffer_text
    local call_or_id = require 'nvim-headband.impl.utils'.call_or_id

    return hl('NvimHeadbandEmptyBuf') .. ' ' .. call_or_id(ubt)
  end

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

  local bufnr = fn.bufnr()

  local bid = fn.bufwinnr(bufnr)
  local bname = fn.bufname()
  local bt = api.nvim_buf_get_option(0, 'bt')
  local ft = api.nvim_buf_get_option(0, 'ft')

  if self.config.buffer_filter(bid, bname, bt, ft) then
    self:disable()
  else
    self:enable()
  end

  local error_handler = function(error)
    ErrorHandler.headband_notify_error_deffered(
      'Error encountered while trying to get the winbar, disabling.\n'
      .. 'Please contact the author and file an issue.'
      .. '\n\n'
      .. error
    )

    self:disable()
  end

  local _, winbar_string = xpcall(self.get_winbar, error_handler, self)

  return winbar_string
end

local get_headband_callback = function(mod, buffer_filter)
  return function()
    local proper_buffer =
      api.nvim_buf_get_option(0, 'buftype') == ''
      and fn.getcmdwintype() == ''

    if proper_buffer then
      vim.wo.winbar = mod.winbar_string
    end
  end
end

function NvimHeadbandWinbarMod:register_autocmd()
  local autocmd = api.nvim_create_autocmd

  autocmd(
    { 'VimEnter', 'BufEnter' },
    {
      pattern = '*',
      group = NvimHeadbandWinbarMod.augroup_id,
      callback = get_headband_callback(NvimHeadbandWinbarMod)
    }
  )
end

function NvimHeadbandWinbarMod:clear_autocmd()
  api.nvim_clear_autocmds({ group = self.augroup_id })
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

  if self.config.enable and (not force) then
    return
  end

  self.config.enable = true
  self:register_autocmd()
  self:soft_enable()
end

local Winbar = {}

Winbar.start = function(config)
  if not config.enable then
    return
  end

  local augroup = function(x)
    return api.nvim_create_augroup(x, { clear = true })
  end

  NvimHeadbandWinbarMod.config = config
  NvimHeadbandWinbarMod.augroup_id = augroup('NvimHeadbandWinbar')
  NvimHeadbandWinbarMod.winbar_string = '%{%v:lua.NvimHeadbandWinbarMod.get()%}'

  NvimHeadbandWinbarMod:enable(true)
end

return Winbar
