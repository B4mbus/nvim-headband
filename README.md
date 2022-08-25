<div align="center">

# nvim-headband - a simple and opinionated winbar
  <div>
    <a href='#-Showcase'>🖼 Showcase</a> |
    <a href='#-Installation'>💾 Installation</a> |
    <a href='#-Configuration'>⚙ Configuration & Usage</a> |
    <a href='#-Highlights'>🎨 Highlights</a> |
    <a href='#-Todo'>🧾 Todo</a>
  </div>
</div>

nvim-headband..
 - is **simple** - you can just install it and you are good to go
 - is **opinionated** - it doesn't give you *all the possible* cofiguration options in the world, it has two simple sections
 - has **sane defaults** - it's very likely that you won't have to change the default configuration

.. but it's still **highly configurable**! See [Configuration](#Configuration) and [Highlights](#Highlights).

# ⚠⚠⚠⚠⚠⚠⚠ WIP ⚠⚠⚠⚠⚠⚠⚠

Still WIP, some things don't work, some things break, some things fly.

## 🖼 Showcase

**TODO**

## 💾 Installation

Install with your favourite package manager, e.g. **[https://github.com/wbthomason/packer.nvim](packer)**:
```lua
use {
  'B4mbus/nvim-headband',
  config = function()
    require 'nvim-headband'.setup {
      -- Optionally, if you want to configure stuff
    }
  end
  requires = {
    { 'SmiteshP/nvim-navic', opt = true } -- required for for the navic section to work
    { 'kyazdani42/nvim-web-devicons', opt = true } -- required for for devicons and default navic_section.separator highlight group
  }
}
```

## ⚙ Configuration

These are the default values

```lua
require 'nvim-headband'.setup {
  enable = true, -- Whether to enable the winbar
  general_separator = '::', -- What will be displayed between the file section and navic section if both are present
  unsaved_buffer_text = '[No name]', -- The text to display for an unsaved buffer (not a readable file)

  file_section = {
    enable = true, -- Whether to enable the file section
    -- Can be 'filename' | 'shortened' | 'shortened_lower' | 'full' | 'full_lower'.
    -- For a path like /home/b4mbus/dev/file.cpp or C:\Users\B4mbus\dev\file.cpp
    -- 'filename' will be file.cpp and file.cpp
    -- 'shortened' will be /h/b/d/file.cpp and C:\U\B\d\file.cpp
    -- 'shortened_lower' will be /h/b/d/file.cpp and c:\u\b\d\file.cpp
    -- 'full' will be /home/b4mbus/dev/file.cpp nd C:\Users\B4mbus\dev\file.cpp
    -- 'full_lower' will be /home/b4mbus/dev/file.cpp nd c:\users\b4mbus\dev\file.cpp
    style = 'filename',
    bold_filename = true, -- Makes the filename bold (set's the NvimHeadbandFilename hl group to bold)

    devicons = {
      enable = true, -- Whether to enable the devicons
      highlight = true -- Whether to highlight the devicons
    },
  },

  navic_section = {
    enable = true, -- Whether to enable the navic section

    depth_limit = 0, -- Passed directly to navic, taken from the navic repo: 'maximum depth of context to be shown. If the context hits this depth limit, it is truncated'
    depth_limit_indicator = symbols.ellipsis, -- Passed directly to navic, taken from the navic repo:  Icon to indicate that depth_limit was hit and the shown context is truncated'

    empty_symbol = {
      symbol = symbols.empty_set, -- A symbol to set when the navic location is available but there's no location to show (e.g. global namespace in some languages)
      highlight = true -- Experimental (TODO??????????????????????????)
    },

    separator = {
      symbol = symbols.nice_arrow, -- The symbol to use as a navic separator
      highlight = true -- Whether to register the default highlight for the navic separator (TODO??????????????????????????)
    },

    icons = {
      default_icons = true, -- Whether to enable the default icons for navic
      -- Can be 'link' | 'none' | 'default'
      -- For 'link' it will use the same highlights as CmpItem*
      -- For 'default' it will set the default vscode-like hl groups (TODO??????????????????????????)
      -- For 'none' it will not color the navic icons
      highlights = 'link'
    },
  }
}

return default_config
```

## 🎨 Highlights

The plugin defines the following highlight groups:

 - **NvimHeadbandFilename** - used for the filename, if `file_section.bold_filename` is set to true this highlight group will have the `bold` attribute set
Apart from that
 - **NvimHeadbandPath** - used for the rest of the path, if `file_section.style` is *'shortened'* or *'full'*
 - **NvimHeadbandSeparator** - used for the separator between the file section and navic section
 - **NvimHeadbandEmptyBuf** - used for the entire winbar when the buffer is unsaved
 - **NvimHeadbandEmptyLoc** - used for the empty location symbol (when navic is available but there's no location available, e.g. in global namespace in some languages)


## 🧾 Todo
 - Register default highlights
 - Setup navic
 - Strip config
 - Add option to disable for filetypes (e.g. GITCOMMIT, etc.) (by default it's only disabled in nofile buffers)
 - Add option to center the winbar
 - Vim docs
 - Add option to make the navic section on the right
 - Add option to make sections 'bubbly' (like lualines bubble theme)
 - VSCode like clickable breadcrumbs
