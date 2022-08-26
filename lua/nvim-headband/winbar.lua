local api = vim.api
local fn = vim.fn
local concat = table.concat
local fmt = string.format
local empty_hl = '%##'

local errors = require 'nvim-headband.error_handling'

local issue_lack_of_devicons_error = function()
  errors.headband_notify(
    'The "kyazdani42/nvim-web-devicons" plugin is not present. Cannot enable devicons for winbar.'
  )
end

local issue_lack_of_navic_error = function()
  errors.headband_notify(
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
    vim.defer_fn(
      function()
        vim.notify(
          'Error encountered while trying to get the winbar, disabling.\n'
          .. 'Please contact the author and file an issue.'
          .. '\n\n'
          .. error,
          vim.log.levels.ERROR,
          {
            title = 'nvim-headband',
            on_open = function(win)
              local buf = vim.api.nvim_win_get_buf(win)
              vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
            end,
          }
        )
      end,
      100
    )

    self:disable()
  end

  local _, winbar_string = xpcall(self.get_winbar, error_handler, self)

  return winbar_string
end

function NvimHeadbandWinbarMod:disable()
  self.config.enable = false

  api.nvim_clear_autocmds({ group = self.augroup_id })

  vim.wo.winbar = ''
end

local Winbar = {}

local get_headband_callback = function()
  return function()
    if api.nvim_buf_get_option(0, 'buftype') == '' and fn.getcmdwintype() == '' then
      vim.wo.winbar = '%{%v:lua.NvimHeadbandWinbarMod.get()%}'
    end
  end
end

--- Enables the nvim-headband winbar
---@param config UserConfig
Winbar.enable = function(config)
  local autocmd = api.nvim_create_autocmd
  local augroup = function(x) return api.nvim_create_augroup(x, { clear = true }) end

  -- TODO: Strip config
  NvimHeadbandWinbarMod.config = config
  NvimHeadbandWinbarMod.augroup_id = augroup('NvimHeadbandWinbar')

  autocmd(
    { 'VimEnter', 'BufEnter' },
    {
      pattern = '*',
      group = NvimHeadbandWinbarMod.augroup_id,
      callback = get_headband_callback()
    }
  )
end

return Winbar
