local fmt = string.format
local api = vim.api
local fn = vim.fn

local hl = require('nvim-headband.impl.utils').hl
local empty_hl = require('nvim-headband.impl.utils').empty_hl

local function issue_lack_of_devicons_error()
  local ErrorHandler = require('nvim-headband.impl.error_handler')

  ErrorHandler.headband_notify_error_deffered(
    'The "kyazdani42/nvim-web-devicons" plugin is not present. Cannot enable devicons for winbar.'
  )
end

local get_devicons_mod = function()
  local conditional_require = require('nvim-headband.impl.utils').conditional_require

  return conditional_require('nvim-web-devicons', issue_lack_of_devicons_error)
end

local function get_preffered_path_separator()
  if fn.has('win32') then
    return '\\'
  else
    return '/'
  end
end

local function format_path(path)
  if fn.has('win32') then
    return path:sub(1, 1) .. ':' .. path:sub(2, -1)
  else
    return '/' .. path
  end
end

local function shorten_path(path)
  local preffered_separator = get_preffered_path_separator()
  local get_first = function(path_elem)
    return path_elem:sub(1, 1)
  end

  local shortened_path = table.concat(
    vim.tbl_map(
      get_first,
      fn.split(path, preffered_separator)
    ),
    preffered_separator
  )

  return format_path(shortened_path)
end

local function reverse_path(path)
  local sep = get_preffered_path_separator()
  local split_path = fn.split(path, sep)

  return table.concat(
    fn.reverse(split_path),
    sep
  )
end

local FileSection = {}

function FileSection:build_full_path(path_without_filename, filename)
  local full_path = path_without_filename

  if self.config.text:find('shortened') then
    full_path = shorten_path(path_without_filename)
  end

  if self.config.text:find('lower') then
    full_path = full_path:lower()
  end

  local preffered_separator = get_preffered_path_separator()

  return
    hl('NvimHeadbandPath')
    .. full_path
    .. preffered_separator
    .. hl 'NvimHeadbandFilename'
    .. filename
    .. empty_hl
end

function FileSection:get_path()
  local text = self.config.text

  local filename = fn.expand('%:p:t')
  local path_without_filename = fn.expand('%:p:h')

  if type(text) == 'function' then
    return text()
  elseif text == 'filename' then
    return hl 'NvimHeadbandFilename' .. filename .. empty_hl
  else
    return self:build_full_path(path_without_filename, filename)
  end
end

function FileSection:format_icon(name, icon)
  local format_string = '%s'

  if self.config.highlights.devicons then
    format_string = '%' .. hl(name) .. format_string
  end

  return fmt(format_string, icon) .. empty_hl
end

function FileSection:get_icon()
  if not self.config.enable_devicons then
    return ''
  end

  local devicons_loaded, devicons = get_devicons_mod()

  if devicons_loaded then
    local filename = vim.fn.expand('%:t')
    local ext = vim.fn.fnamemodify(filename, ':e')

    local icon, name = devicons.get_icon(filename, ext)
    if not icon or not name then
      return ''
    end

    return self:format_icon(name, icon)
  end
end

function FileSection:get_file_section()
  local icon = self:get_icon()
  local path = self:get_path()

  if self.config.reversed then
    path = reverse_path(path)
  end

  local wrapper = require('nvim-headband.impl.winbar.shared').evaluate_wrap(self.config.wrap)

  return wrapper(icon .. ' ' .. path .. empty_hl)
end

function FileSection.get(config)
  local self = FileSection

  if not config.enable then
    return ''
  end

  self.config = config

  return self:get_file_section()
end

return FileSection
