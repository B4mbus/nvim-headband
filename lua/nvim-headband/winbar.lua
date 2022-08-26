local api = vim.api
local fn = vim.fn
local concat = table.concat
local fmt = string.format
local empty_hl = '%##'

local ErrorHandler = require 'nvim-headband.error_handler'

local issue_lack_of_devicons_error = function()
  ErrorHandler.headband_notify_error_deffered(
    'The "kyazdani42/nvim-web-devicons" plugin is not present. Cannot enable devicons for winbar.'
  )
end

local issue_lack_of_navic_error = function()
  ErrorHandler.headband_notify_error_deffered(
    'The "SmiteshP/nvim-navic" plugin is not present. Cannot enable navic for winbar.'
  )
end

local conditional_require = function(name, handler)
  if package.preload[name] then
      return true, require(name)
    end

  local loaded, mod = xpcall(
    require,
    handler,
    name
  )

  return loaded, mod
end

local get_devicons_mod = function()
  return conditional_require('nvim-web-devicons', issue_lack_of_devicons_error)
end

local get_navic_mod = function()
  return conditional_require('nvim-navic', issue_lack_of_navic_error)
end

local get_preffered_path_separator = function()
  if fn.has('win32') then
    return '\\'
  else
    return '/'
  end
end

local hl = function(group)
  return '%#' .. group .. '#'
end

local format_path = function(path)
  if fn.has('win32') then
    return path:sub(1, 1) .. ':' .. path:sub(2, -1)
  else
    return '/' .. path
  end
end

NvimHeadbandWinbarMod = {}

function NvimHeadbandWinbarMod:get_file_section_icon()
  local devicons_enabled = self.config.file_section.devicons.enable
  if not devicons_enabled then
    return ''
  end

  local devicons_loaded, devicons = get_devicons_mod()

  if devicons_loaded then
    local ft = api.nvim_buf_get_option(0, 'ft')
    local icon, name = devicons.get_icon_by_filetype(ft)
    if not icon or not name then
      return ''
    end

    local format_string = '%s'

    if self.config.file_section.devicons.highlight then
      format_string = '%' .. hl(name) .. format_string
    end

    return fmt(format_string, icon)
  end
end

function NvimHeadbandWinbarMod:conditionally_lower_path(path)
  if self.config.file_section.text:find('shortened') then
    return path:tolower()
  end
end

function NvimHeadbandWinbarMod:conditionally_shorten_path(path)
  if self.config.file_section.text:find('full') then
    return self:conditionally_lower_path(path)
  end

  local preffered_separator = get_preffered_path_separator()
  local get_first = function(path_elem)
    return path_elem:sub(1, 1)
  end

  local formatted_path = format_path(
    concat(
      vim.tbl_map(
        get_first,
        fn.split(path, preffered_separator)
      ),
      preffered_separator
    ) .. preffered_separator
  )

  return self:conditionally_lower_path(formatted_path)
end

function NvimHeadbandWinbarMod:get_file_string()
  local text = self.config.file_section.text

  local filename = fn.expand('%:p:t')
  local path_without_filename = fn.expand('%:p:h')

  if text == 'filename' then
    return hl('NvimHeadbandFilename') .. filename .. empty_hl
  else
    local possibly_shortened_path = self:conditionally_shorten_path(path_without_filename)

    return
      hl('NvimHeadbandPath')
      .. possibly_shortened_path
      ..hl('NvimHeadbandFilename')
      .. filename
      .. empty_hl
  end
end

function NvimHeadbandWinbarMod:get_file_section()
  if not self.config.file_section.devicons.enable then
    return ''
  end

  local icon = self:get_file_section_icon()
  local file_string = self:get_file_string()

  return
    icon
    .. ' '
    .. file_string
    .. empty_hl
end

function NvimHeadbandWinbarMod:get_navic_hl()
  if self.config.navic_section.empty_symbol.highlight then
    return hl('NvimHeadbandEmptyLoc')
  else
    return ''
  end
end

function NvimHeadbandWinbarMod:get_empty_symbol()
  local empty_symbol = self.config.navic_section.empty_symbol.symbol

  if empty_symbol == '' then
    return ''
  else
    return
      self:get_navic_hl()
      .. empty_symbol
  end
end

function NvimHeadbandWinbarMod:get_navic_location(navic)
  local loc = navic.get_location()

  if loc == '' then
    return self:get_empty_symbol()
  else
    return loc
  end
end

function NvimHeadbandWinbarMod:get_navic_section()
  if not self.config.navic_section.enable then
    return ''
  end

  local navic_loaded, navic = get_navic_mod()

  if navic_loaded and navic.is_available() then
    return self:get_navic_location(navic)
  else
    return ''
  end
end

function NvimHeadbandWinbarMod:separator_available(navic_string)
  local _, navic = get_navic_mod()

  return ((self.config.file_section.enable)
    and (self.config.navic_section.enable))
    and (navic.is_available())
    and (navic_string ~= '')
end

function NvimHeadbandWinbarMod:get_separator_conditionally(navic_string)
  if not self:separator_available(navic_string) then
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
    return hl('NvimHeadbandEmptyBuf') .. ' ' .. self.config.unsaved_buffer_text
  end

  local navic_section = self:get_navic_section()

  return
    hl('WinBar')
    .. ' '
    .. self:get_file_section()
    .. self:get_separator_conditionally(navic_section)
    .. navic_section
end

function NvimHeadbandWinbarMod.get()
  local self = NvimHeadbandWinbarMod

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

local get_headband_callback = function(mod)
  return function()
    if api.nvim_buf_get_option(0, 'buftype') == '' and fn.getcmdwintype() == '' then
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

function NvimHeadbandWinbarMod:disable()
  if not self.config.enable then
    return
  end

  self.config.enable = false
  self:clear_autocmd()

  vim.wo.winbar = ''
end

function NvimHeadbandWinbarMod:enable(force)
  local force = force or false

  if self.config.enable and (not force) then
    return
  end

  self.config.enable = true
  self:register_autocmd()

  vim.wo.winbar = self.winbar_string
end

local Winbar = {}

Winbar.start = function(config)
  local augroup = function(x)
    return api.nvim_create_augroup(x, { clear = true })
  end

  NvimHeadbandWinbarMod.config = config
  NvimHeadbandWinbarMod.augroup_id = augroup('NvimHeadbandWinbar')
  NvimHeadbandWinbarMod.winbar_string = '%{%v:lua.NvimHeadbandWinbarMod.get()%}'

  NvimHeadbandWinbarMod:enable(true)
end

return Winbar
