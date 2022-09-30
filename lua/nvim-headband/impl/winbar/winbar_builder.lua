local WinbarBuilder = {}

local hl = require('nvim-headband.impl.utils').hl
local empty_hl = require('nvim-headband.impl.utils').empty_hl

local function patch_highlight_config(config)
  config.file_section.highlights = {}
  config.file_section.highlights.devicons = config.styling.highlights.devicons

  config.location_section.highlights = {}
  config.location_section.highlights.location_icons = config.styling.highlights.location_icons

  return config
end

local function in_unsaved_buffer()
  return vim.fn.filereadable(vim.fn.expand '%:p') == 0
end

function WinbarBuilder:separator_available(loc_available)
  local fs = self.config.file_section
  local ls = self.config.location_section

  return
    fs.enable
    and ls.enable
    and loc_available
    and fs.position == ls.position
end

function WinbarBuilder:get_separator_conditionally(loc_available)
  if not self:separator_available(loc_available) then
    return ''
  end

  local call_or_id = require('nvim-headband.impl.utils').call_or_id

  return
    hl('NvimHeadbandSeparator')
      .. ' '
      .. call_or_id(self.config.separator_text)
      .. ' '
      .. empty_hl
end

function WinbarBuilder:build_unsaved_buffer_winbar()
  local unsaved_buffer_text = self.config.unsaved_buffer_text
  local call_or_id = require('nvim-headband.impl.utils').call_or_id

  return
    hl('NvimHeadbandUnsavedBuf')
      .. ' '
      .. call_or_id(unsaved_buffer_text)
end

function WinbarBuilder:get_sections_strings()
  -- HACK: hacky as b4LLz, but fuck it, no one's gonna see :tf: :tf:
  self.config = patch_highlight_config(self.config)

  local loc_section_mod = require('nvim-headband.impl.winbar.location_section')
  local loc_available, loc_section = loc_section_mod.get(self.config.location_section)

  local file_section_mod = require('nvim-headband.impl.winbar.file_section')

  return
    file_section_mod.get(self.config.file_section),
    self:get_separator_conditionally(loc_available and (loc_section ~= '')),
    loc_section
end

function WinbarBuilder:get_sections_with_layout()
  local fstring, sep, lstring = self:get_sections_strings()

  local fpos = self.config.file_section.position
  local lpos = self.config.location_section.position

  if fpos == 'left' and lpos == 'left' then
    return '' .. fstring .. sep .. '' .. lstring

  elseif fpos == 'right' and lpos == 'right' then
    return '%=' .. fstring .. sep .. '' .. lstring

  elseif fpos == 'left' and lpos == 'right' then
    return '' .. fstring .. sep .. '%=' .. lstring

  elseif fpos == 'right' and lpos == 'left' then
    return '' .. lstring .. sep .. '%=' .. fstring

  else
    error 'The "position" option must be a string of either "left" or "right".'

  end
end

function WinbarBuilder.build(config)
  local self = WinbarBuilder

  self.config = config

  if in_unsaved_buffer() then
    return self:build_unsaved_buffer_winbar()
  else
    local winbar_string = self:get_sections_with_layout()

    return hl('WinBar') .. ' ' .. winbar_string .. ' '
  end
end

return WinbarBuilder
