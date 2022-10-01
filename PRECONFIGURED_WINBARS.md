## 🖼 A few preconfigured winbars

### Default (demo 1)
![Winbar default](../media/default.png)
This is the default. You don't need to change or do anything for it to work.

### Winbar with shortened path (demo 2)
![Winbar with shortened path](../media/shortened_path.png)
```lua
use {
  'B4mbus/nvim-headband',
  config = function()
    require('nvim-headband').setup {
      require('nvim-headband.preconfigured.demo2')
    }
  end
  requires = {
    { 'SmiteshP/nvim-navic' } -- required for for the navic section to work
    { 'kyazdani42/nvim-web-devicons' } -- required for for devicons and default location_section.separator highlight group
  }
}
```

<details>
	<summary><b>Code</b></summary>

<br/>

```lua
return {
  file_section = {
    text = 'shortened_lower'
  }
}
```

</details>

### Winbar with location on the right (demo 3)
![Winbar with location on the right](../media/location_on_right.png)

```lua
use {
  'B4mbus/nvim-headband',
  config = function()
    require('nvim-headband').setup {
      require('nvim-headband.preconfigured.demo3')
    }
  end
  requires = {
    { 'SmiteshP/nvim-navic' } -- required for for the navic section to work
    { 'kyazdani42/nvim-web-devicons' } -- required for for devicons and default location_section.separator highlight group
  }
}
```

<details>
	<summary><b>Code</b></summary>

<br/>

```lua
return {
  file_section = {
    text = 'shortened_lower'
  },

  location_section = {
    position = 'right'
  }
}
```

</details>

### Winbar with bubbles (demo 4)
![Winbar with bubbles](../media/bubbles.png)

```lua
use {
  'B4mbus/nvim-headband',
  config = function()
    require('nvim-headband').setup {
      require('nvim-headband.preconfigured.demo4')
    }
  end
  requires = {
    { 'SmiteshP/nvim-navic' } -- required for for the navic section to work
    { 'kyazdani42/nvim-web-devicons' } -- required for for devicons and default location_section.separator highlight group
  }
}
```

<details>
	<summary><b>Code</b></summary>

<br/>

```lua
local color = '#A7C7E7'

vim.api.nvim_set_hl(0, 'NvimHeadbandFilename', { fg = '#000000', bg = color })
vim.api.nvim_set_hl(0, 'NvimHeadbandLocSeparator', { fg = '#6d8086', bg = color })
vim.api.nvim_set_hl(0, 'NvimHeadbandLocText', { fg = '#112233', bg = color })

vim.api.nvim_set_hl(0, 'BubblesFront', { fg = color })

local reverse_arrow = require 'nvim-headband.symbols'.reverse_nice_arrow
local bubbles_wrap = { '%#BubblesFront#', '%#BubblesFront#' }

require 'nvim-headband'.setup {
  file_section = {
    wrap = bubbles_wrap
  },

  location_section = {
    wrap = bubbles_wrap,

    separator = reverse_arrow,

    empty_symbol = '',

    position = 'right',
  }
}
```

</details>
