# ⚙ Configuration & Usage

## Usage

Nvim-headband allows disabling, enabling and toggling on the fly:
```lua
require('nvim-headband').disable() -- Disables
require('nvim-headband').enables() -- Enables
require('nvim-headband').toggle() -- Toggles
```
## Configuration

### Symbols

Nvim-headband exports all internally used symbols, they can be accessed via `require('nvim-headband.symbols')`:
```lua
{
  empty_set = '∅',
  ellipsis = '…',
  nice_arrow = '❯',
  reverse_nice_arrow = '❮',
}
```

### Wraps

Every section has a `wrap` option, which is supposed to be `nil`, an array of two strings or a function returning two strings.  
By default the entire winbar is wrapped in `{ ' ', ' ' }` and both `file_section` and `location_section` are wrapped in `nil` (no wrap).

### Filters

Filters are used to filter out unwanted windows. A filter should be a valid `FilterFunc`:
```lua
--- Basically asks a question 'should this window be excluded from having a winbar?', that is, if it returns true, a window will not have a winbar
---@alias FilterFunc fun(bname: string, bt: string, ft: string, prev: boolean): boolean
```
The default filter looks like this:
```lua
strict_combine(
  bt_filter({
    'NvimTree',
    'nerdtree',
    'neo-tree',
    'packer',
    'alpha',
    'dashboard',
    'startify',
    'nofile',
  }),
  ft_filter({
    'gitcommit',
    'NeogitCommitMessage',
    'NeogitStatus',
  })
)
```

By default `bname_filter`, `ft_filter`, `bt_filter`, `combine` and `strict_combine` are exported.  
They can be accessed via `require('nvim-headband.filters')`:
```lua
local Filters = {}

-- Filters out based on buffertype
function Filters.bt_filter(buffertypes)
  return function(bname, bt, ft, prev)
    return prev or vim.tbl_contains(buffertypes, bt)
  end
end

-- Filters out based on filetype
function Filters.ft_filter(filetypes)
  return function(bname, bt, ft, prev)
    return prev or vim.tbl_contains(filetypes, ft)
  end
end

-- Filters out based on buffername
function Filters.bname_filter(bufnames)
  return function(bname, bt, ft, prev)
    return prev or vim.tbl_contains(bufnames, bname)
  end
end

-- Combines several filters together, but doesn't exit until the last filter.
-- This can be used to use the previous filter's return value in the next filter (the prev argument)
function Filters.combine(...)
  local filters = { ... }

  return function(bname, bt, ft, prev)
    local prev = prev or false

    for _, filter in ipairs(filters) do
      prev = filter(bname, bt, ft, prev)
    end

    return prev
  end
end

-- Combines several filters together, but exists eagerly, as soon as any filter returns `true`
function Filters.strict_combine(...)
  local filters = { ... }

  return function(bname, bt, ft, prev)
    local prev = prev or false

    for _, filter in ipairs(filters) do
      prev = filter(bname, bt, ft, prev)

      if prev then
        return true
      end
    end

    return false
  end
end

return Filters
```

This is the default configuration:
```lua
local symbols = require('nvim-headband.symbols')
-- All default symbols are exported to the user and can be accessed via require('nvim-headband.symbols')

local strict_combine = require('nvim-headband.filters').strict_combine
local bt_filter = require('nvim-headband.filters').bt_filter
local ft_filter = require('nvim-headband.filters').ft_filter

local default_config = {
  enable = true, -- whether to enable the winbar

  enable_if_single_window = true, -- should the winbar be visible even if there's only one window open?

  window_filter = strict_combine( -- filters out certain windows
    bt_filter {
      'NvimTree',
      'nerdtree',
      'neo-tree',
      'packer',
      'alpha',
      'dashboard',
      'startify',
      'nofile',
    },
    ft_filter {
      'gitcommit',
      'NeogitCommitMessage',
      'NeogitStatus',
    }
  ),

  separator_text = '::', -- the text between the location section and file section, appears only when they both have the same position and both are enabled and accessible
  unsaved_buffer_text = '%f', -- text to use for not-readable buffers (e.g. unsaved files, scratch buffers), in the future it will be a whole section like file_section for the sake of configurativity

  wrap = { ' ', ' ' }, -- see #wrap above

  file_section = { -- the configuration for the file section
    enable = true, -- whether to enable the file section

    text = 'filename', -- how the file section should be displayed, can be 'full'|'full_lower'|'filename'|'shortened| 'shortened_lower'

    wrap = nil, -- see #wrap above

    enable_devicons = true, -- whether to enable the devicons

    position = 'left', -- the position of the file section, can be `left`|`right`
    reversed = false, -- whether the file section should be reversed
  },

  location_section = { -- the configuration for the location section
    enable = true, -- whether to enable the location section

    depth_limit = 0, -- how many items are allowed max
    depth_limit_indicator = symbols.ellipsis, -- the symbol to use to indicate overflow

    wrap = nil, -- see #wrap above

    empty_symbol = symbols.empty_set, -- symbol to use when the location is available but there's nothing to show (e.g. global namespace)

    separator = symbols.nice_arrow, -- the separator between the semantic elements

    icons = 'default', -- can be 'none' to disable, 'default' to register default or a table to register custom ones, see https://github.com/SmiteshP/nvim-navic#-customise

    position = 'left', -- the position of the location section, can be `left`|`right`
    reversed = false, -- whether the location section should be reversed
  },

  styling = { -- configuration for styles
    highlights = {
      devicons = true, -- whether to highlight devicons
      default_location_separator = true, -- whether to setup a default location separator highlight
      location_icons = 'link', -- can be 'none' to disable, 'default' to vscode-y hl groups or 'link' to link to respective CmpItem* groups
    },
    bold_filename = true, -- whether to make the filename bold
  },
}

return default_config
```

## Highlights

These are the available groups:
 - **NvimHeadbandFilename** - for the filename part of the path ('full', 'shortened' or 'filename')
 - **NvimHeadbandPath** - for the path-without-filename part of the path ('full' or 'shortened')
 - **NvimHeadbandSeparator** - for the general separator
 - **NvimHeadbandLocSeparator** - for the location separator
 - **NvimHeadbandLocText** - for the location text
 - **NvimHeadbandUnsavedBuf** - when the buffer is unsaved
 - **NvimHeadbandEmptyLocSymbol** - for the empty location symbol

For wrapping to work nicely, if `NvimHeadbandLocText`, `NvimHeadbandPath` or/and `NvimHeadbandFilename` have custom background set, the plugin will automatically extract it and use it to highlight devicons' and location items' backgrounds.
