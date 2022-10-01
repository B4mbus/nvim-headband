--[[
Available groups:
 - NvimHeadbandFilename - for the filename part of the path ('full', 'shortened' or 'filename')
 - NvimHeadbandPath - for the path-without-filename part of the path ('full' or 'shortened')
 - NvimHeadbandSeparator - for the general separator
 - NvimHeadbandLocSeparator - for the location separator
 - NvimHeadbandLocText - for the location text
 - NvimHeadbandUnsavedBuf - when the buffer is unsaved
 - NvimHeadbandEmptyLocSymbol - for the empty location symbol
]]

local function hl_exists(name)
  return vim.fn.hlID(name) ~= 0
end

local function hl(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

local function register_bold_filename()
  local filename_hl = 'NvimHeadbandFilename'

  local ok, existing_hl = pcall(vim.api.nvim_get_hl_by_name, filename_hl, {})
  local existing_hl = ok and existing_hl or {}

  hl(filename_hl, vim.tbl_extend('force', { bold = true }, existing_hl))
end

local function register_linked_navic_icons_hls()
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
end

local function register_default_navic_icons_hls()
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

local function convert_decimal_colors_to_hex_strings(definition)
  for attr, val in pairs(definition) do
    if attr == 'foreground' or attr == 'background' then
      definition[attr] = vim.fn.printf('#%x', val)
    end
  end

  return definition
end

local function extract_hls_definition(name)
  return convert_decimal_colors_to_hex_strings(
    vim.api.nvim_get_hl_by_name(name,true)
  )
end

local function remove_key(table, key)
  table[key] = nil
  return table
end

local Highlights = {}

---Returns the highlight definition without foreground, keeping all other attributes
---@param name string The name of the highlight
function Highlights.hl_definition_no_fg(name)
  return remove_key(extract_hls_definition(name), 'foreground')
end

---Returns the highlight definition without background, keeping all other attributes
---@param name string The name of the highlight
function Highlights.hl_definition_no_bg(name)
  return remove_key(extract_hls_definition(name), 'bcakground')
end

function Highlights.setup_highlights(config)
  local highlights = config.highlights

  if config.bold_filename then
    register_bold_filename()
  end

  local loc_sep_hl = 'NvimHeadbandLocSeparator'
  if highlights.default_location_separator and not hl_exists(loc_sep_hl) then
    hl(loc_sep_hl, { fg = '#6d8086' })
  end

  if config.location_icons == 'link' then
    register_linked_navic_icons_hls()
  elseif highlights.location_icons == 'default' then
     register_default_navic_icons_hls()
  end
end

return Highlights
