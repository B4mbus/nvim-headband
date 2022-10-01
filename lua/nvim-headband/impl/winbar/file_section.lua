local fmt = string.format
local api = vim.api
local fn = vim.fn
local Highlights = require('nvim-headband.impl.highlights')


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
    .. hl('NvimHeadbandFilename')
    .. filename
    .. empty_hl
end

function FileSection:get_path()
  local filename = fn.expand('%:p:t')

  if self.config.text == 'filename' then
    return hl('NvimHeadbandFilename') .. filename .. empty_hl
  else
    local path_without_filename = fn.expand('%:p:h')

    return self:build_full_path(path_without_filename, filename)
  end
end

function FileSection:get_highlight_next_to_icon()
  if self.config.text == 'filename' then
    return Highlights.highlight_definition('NvimHeadbandFilename')
  else
    return Highlights.highlight_definition('NvimHeadbandPath')
  end
end

function FileSection:create_and_activate_hl_definition(original_name, patched_name, keep_foreground)
  local original_hl_def = Highlights.highlight_definition(original_name)
  local highlight_next_to_icon_bg = self:get_highlight_next_to_icon().background

  original_hl_def.background = highlight_next_to_icon_bg

  if not keep_foreground then
    original_hl_def = Highlights.remove_fg_from_definiton(original_hl_def)
  end

  vim.api.nvim_set_hl(0, patched_name, original_hl_def)
end

function FileSection:create_local_patched_hl(original_name, keep_foreground)
  local patched_name = 'NvimHeadband' .. original_name .. 'Patched'

  if not Highlights.hl_exists(patched_name) then
    self:create_and_activate_hl_definition(original_name, patched_name, keep_foreground)
  end

  return patched_name
end

function FileSection:hl_icon(name, icon)
  local hl_name = name

  if Highlights.definition_has_bg(self:get_highlight_next_to_icon()) then
    hl_name = self:create_local_patched_hl(
      name,
      self.config.highlights.devicons -- keep foreground if highlights.devicons is true
    )
  end

  icon = hl(hl_name) .. icon

  return icon .. empty_hl
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

    return self:hl_icon(name, icon)
  end
end

function FileSection:get_file_section()
  local icon = self:get_icon()
  local path = self:get_path()

  if self.config.reversed then
    path = reverse_path(path)
  end

  local wrapper = require('nvim-headband.impl.winbar.shared').create_wrapper(self.config.wrap)

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
