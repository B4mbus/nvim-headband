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

.. but it's still **highly configurable**! See [Configuration](#-Configuration) and [Highlights](#-Highlights).

## 🖼 Showcase

***TODO***

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
    { 'kyazdani42/nvim-web-devicons', opt = true } -- required for for devicons and default location_section.separator highlight group
  }
}
```

## ⚙ Configuration

See [Configuration & Usage](configuration-and-usage.md).

## 🎨 Highlights

See [Configuration & Usage - Highlights](configuration-and-usage.md#-Highlights).

## 🧾 Todo

### 📚 Docs
 1. Vim docs

### 🔜 Soon
 1. For shoretened paths an option to make them full for a second (`:toogle_short()`?)
 2. Clickable and hoverable items in sections (directories, location items)
