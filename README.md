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

## 🖼 Showcase

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

Ło kurwa

## 🎨 Highlights

 - NvimHeadbandFilename
 - NvimHeadbandPath
 - NvimHeadbandSeparator
 - NvimHeadbandEmptyBuf
 - NvimHeadbandEmptyLoc

## 🧾 Todo
 - Add option to disable for filetypes (e.g. GITCOMMIT, etc.) (by default it's only disabled in nofile buffers)
 - Strip config
 - Register default highlights
 - Setup navic
 - Strip config
 - Add option to disable for filetypes (e.g. GITCOMMIT, etc.) (by default it's only disabled in nofile buffers)
 - Add option to center the winbar
 - Vim docs
 - Add option to make the navic section on the right
 - Setup navic
 - VSCode like clickable breadcrumbs
