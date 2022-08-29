--[[

Available groups:
 - NvimHeadbandFilename - for the filename part of the path ('full', 'shortened' or 'filename')
 - NvimHeadbandPath - for the path-without-filename part of the path ('full' or 'shortened')
 - NvimHeadbandSeparator - for the general separator
 - NvimHeadbandLocSeparator - for the location separator
 - NvimHeadbandUnsavedBuf - when the buffer is unsaved
 - NvimHeadbandEmptyLocSymbol - for the empty location symbol
--]]


local Highlights = {}

function Highlights.setup_highlights(config)
  local highlights = config.highlights

  local hl = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  if config.bold_filename then
    hl('NvimHeadbandFilename', { bold = true })
  end

  if highlights.default_location_separator then
    hl('NvimHeadbandLocSeparator', { fg = '#6d8086' })
  end

  if config.location_icons == 'link' then
    local group_suffixes = {
      'Field',
      'Property',
      'Event',
      'Text',
      'Enum',
      'Keyword',
      'Constant',
      'Constructor',
      'Reference',
      'Function',
      'Method',
      'Struct',
      'Class',
      'Module',
      'Operator',
      'Variable',
      'File',
      'Unit',
      'Snippet',
      'Folder',
      'Value',
      'EnumMember',
      'Interface',
      'Color',
      'TypeParameter',
    }

    for _, suffix in ipairs(group_suffixes) do
      hl('NavicIcons' .. suffix, { link = 'CmpItemKind' .. suffix })
    end
  elseif highlights.location_icons == 'default' then
    local groups = {
      Variable = { fg = '#9CDCFE' },
      Interface = { fg = '#9CDCFE' },
      Text = { fg = '#9CDCFE' },
      Function = { fg = '#C586C0' },
      Method = { fg = '#C586C0' },
      Keyword = { fg = '#D4D4D4' },
      Property = { fg = '#D4D4D4' },
      Unit = { fg = '#D4D4D4' },
    }

    for group_suffix, opts in pairs(groups) do
      hl('CmpItemKind' .. group_suffix, opts)
    end
  end
end

return Highlights
