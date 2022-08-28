local WinbarBuilder = {}

local hl = require 'nvim-headband.impl.utils'.hl
local empty_hl = require 'nvim-headband.impl.utils'.empty_hl

local patch_highlight_config = function(config)
  config.file_section.highlights = {}
  config.file_section.highlights.devicons = config.highlights.devicons

  config.location_section.highlights = {}
  config.location_section.highlights.location_icons = config.highlights.location_icons

  return config
end

local in_unsaved_buffer = function()
  return vim.fn.filereadable(
    vim.fn.expand('%:p')
  ) == 0
end

function WinbarBuilder:separator_available(loc_available)
  local fs = self.config.file_section
  local ls = self.config.location_section

  return
    fs.enable
    and ls.enable
    and loc_available
end

function WinbarBuilder:get_separator_conditionally(loc_available)
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

function WinbarBuilder:build_unsaved_buffer_winbar()
  local ubt = self.config.unsaved_buffer_text
  local call_or_id = require 'nvim-headband.impl.utils'.call_or_id

  return hl('NvimHeadbandEmptyBuf') .. ' ' .. call_or_id(ubt)
end

WinbarBuilder.build = function(config)
  local self = WinbarBuilder

  self.config = config

  if in_unsaved_buffer() then
    return self:build_unsaved_buffer_winbar()
  end

  -- HACK: hacky as b4LLz, but fuck it, no one's gonna see :tf: :tf:
  self.config = patch_highlight_config(self.config)

  local loc_section_mod = require 'nvim-headband.impl.winbar.location_section'
  local loc_available, loc_section = loc_section_mod.get(self.config.location_section)

  local file_section_mod = require 'nvim-headband.impl.winbar.file_section'

  return hl('WinBar')
    .. ' '
    .. file_section_mod.get(self.config.file_section)
    .. self:get_separator_conditionally(loc_available and (loc_section ~= ''))
    .. loc_section
    .. ' '
end

return WinbarBuilder
