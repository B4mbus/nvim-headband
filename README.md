# Do not use this plugin :p

I originally made this plugin right before winbar went into master, in a couple of days, not thinking of any architecture, without prior bigger experience and with barely any sleep, which resulted in a plugin that isn't well considered and full of bugs. The best I can do to this plugin is almost completely rewrite it, but I don't really fancy to do so, I'd like to direct my attention into other projects I think would be more valuable to the community. There are already plugins out there that do the same (but better), like [**barbecue.nvim**](https://github.com/utilyre/barbecue.nvim) and statusline plugins have a winbar feature as well.

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
 - is **simple** - you can just install it, call setup and you are good to go
 - is **opinionated** - it doesn't give you *all the possible* cofiguration options in the world, it has two simple sections
 - has **sane defaults** - it's very likely that you won't have to change the default configuration

.. but it's still **highly configurable**! See [Configuration](#-Configuration) and [Highlights](#-Highlights).

## 🖼 Showcase

I'd like me a winbar!
![Winbar default](../media/default.png)
Although I'd like to see a little bit more of the path..
![Winbar with shortened path](../media/shortened_path.png)
Hmmm.. And it'd be nice if the location was on the right!
![Winbar with location on the right](../media/location_on_right.png)
Ooooh! And I like bubbles, wonder if..
![Winbar with bubbles](../media/bubbles.png)

Perfect!  
<sup>
All the above and more preconfigured winbars can be [**found here**](PRECONFIGURED_WINBARS.md).
</sup>

## 💾 Installation

Install with your favourite package manager, e.g. **[https://github.com/wbthomason/packer.nvim](packer)**:
```lua
use {
  'B4mbus/nvim-headband',
  config = function()
    require('nvim-headband').setup {
      -- Your configuration goes here
    }
  end,
  after = 'nvim-web-devicons',
  requires = {
    { 'SmiteshP/nvim-navic' } -- required for for the navic section to work
    { 'kyazdani42/nvim-web-devicons' } -- required for for devicons and default location_section.separator highlight group
  }
}
```

## ⚙ Configuration

See [Configuration & Usage](CONFIGURATION_AND_USAGE.md).

## 🎨 Highlights

See [Configuration & Usage - Highlights](CONFIGURATION_AND_USAGE.md#-Highlights).

### 🔜 Soon
 1. For shortened paths an option to make them full for a second (`:toogle_short()`?)
 2. Clickable and hoverable items in sections (directories, location items)
 3. Make `unsaved_buffer` a section like file_section so that it's easier to configure it's behavior
 4. Vim docs
 5. Add an option to center both sections
