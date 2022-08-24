local api = vim.api
local fn = vim.fn
local concat = table.concat
local fmt = string.format

local notif = require 'nvim-headband.notifications'

local empty_hl = '%##'

local issue_lack_of_devicons_error = function()
  notif.issue_headband_error(
    'The "kyazdani42/nvim-web-devicons" plugin is not present. Cannot enable devicons for winbar.'
  )
end

local issue_lack_of_navic_error = function()
  notif.issue_headband_error(
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
      format_string = '%%#' .. name .. '#' .. format_string
    end

    return fmt(format_string, icon)
  end
end

function NvimHeadbandWinbarMod:conditionally_shorten_path(path)
  if self.config.file_section.style == 'full' then
    return path
  end

  local preffered_separator = get_preffered_path_separator()
  local return_first = function(path_elem)
    return path_elem[1]
  end

  return concat(
    unpack(
      vim.tbl_map(
        fn.split(path, preffered_separator),
        return_first
      )
    ),
    preffered_separator
  )
end

function NvimHeadbandWinbarMod:get_file_string()
  local style = self.config.file_section.style

  local filename = fn.expand('%:p:t')
  local path_without_filename = fn.expand('%::h')

  if style == 'filename' then
    return '%#NvimHeadbandFilename#' .. filename .. empty_hl
  else
    local possibly_shortened_path = self.conditionally_shorten_path(path_without_filename)

    return
      '%#NvimHeadbandPath#'
      .. possibly_shortened_path
      ..'%#NvimHeadbandFilename#'
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
    return '%#NvimHeadbandEmptyLoc'
  else
    return ''
  end
end

function NvimHeadbandWinbarMod:get_navic_section()
  if not self.config.navic_section.enable then
    return ''
  end

  local navic_loaded, navic = xpcall(
    require,
    issue_lack_of_navic_error,
    'nvim-navic'
  )

  if navic_loaded then
    local loc = navic.get_location()
    local config = self.config.navic_section

    if loc == '' then
      return
        self:get_navic_hl()
        .. config.empty_symbol.symbol
    else
      return loc
    end
  end
end

function NvimHeadbandWinbarMod:separator_available()
  return (self.config.file_section.enable)
    or (self.config.navic_section.enable)
    or (get_navic_mod().is_available())
end

function NvimHeadbandWinbarMod:get_separator()
  if not self:separator_available() then
    return ''
  end

  return
    '%#NvimHeadbandSeparator#'
    .. ' '
    .. self.config.general_separator
    .. ' '
    .. empty_hl
end

function NvimHeadbandWinbarMod.get()
  local file_readable = fn.filereadable(fn.expand('%:p'))

  if file_readable == 0 then
    return '%#NvimHeadbandEmptyBuf# ' .. self.config.empty_buffer_text
  end

  local self = NvimHeadbandWinbarMod

  local preamble = '%#WinBar# '
  local file_section = self:get_file_section()
  local separator = self:get_separator()
  local navic_section = self:get_navic_section()


  return
    preamble
    .. file_section
    .. separator
    .. navic_section
end

local M = {}

--- Enables the nvim-headband winbar
---@param config UserConfig
M.enable = function(config)
  local autocmd = api.nvim_create_autocmd
  local augroup = function(x) api.nvim_create_augroup(x, { clear = true }) end

  -- TODO: Strip config
  NvimHeadbandWinbarMod.config = config

  autocmd(
    { 'VimEnter', 'BufEnter' },
    {
      pattern = '*',
      group = augroup('NvimHeadbandWinbar'),
      callback = function()
        if api.nvim_buf_get_option(0, 'buftype') == '' then
          vim.wo.winbar = '%{%v:lua.NvimHeadbandWinbarMod.get()%}'
        end
      end
    }
  )
end

return M
