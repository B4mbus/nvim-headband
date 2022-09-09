local api = vim.api
local fn = vim.fn

local ErrorHandler = require('nvim-headband.impl.error_handler')

local function get_buffer_context()
  local bname = fn.bufname()
  local bt = api.nvim_buf_get_option(0, 'bt')
  local ft = api.nvim_buf_get_option(0, 'ft')

  return bname, bt, ft
end

local function get_headband_callback(self)
  return function()
    local proper_buffer =
      api.nvim_buf_get_option(0, 'buftype') == ''
      and fn.getcmdwintype() == ''
      and self.config.window_filter(get_buffer_context())

    if proper_buffer then
      vim.wo.winbar = self.winbar_string
    end
  end
end

--- The global winbar mod, contains the whole needed state for the winbar to work
NvimHeadbandWinbarMod = {}

function NvimHeadbandWinbarMod.get_winbar(self)
  if not self.config.enable then
    return ''
  end

  local WinbarBuilder = require('nvim-headband.impl.winbar.winbar_builder')
  return WinbarBuilder.build(self.config)
end

function NvimHeadbandWinbarMod.get()
  local self = NvimHeadbandWinbarMod

  local error_handler = function(error)
    ErrorHandler.headband_notify_error_deffered(
      'Error encountered while trying to get the winbar, disabling.\n'
        .. 'Make sure your config is correct.\n'
        .. 'If you are sure it\'s a bug, please file an issue on "https://github.com/B4mbus/nvim-headband".'
        .. '\n\n'
        .. error
    )

    self:disable()
  end

  local _, winbar_string = xpcall(self.get_winbar, error_handler, self)

  return winbar_string
end

function NvimHeadbandWinbarMod:register_autocmd()
  api.nvim_create_autocmd(
    { 'VimEnter', 'BufEnter' },
    {
      pattern = '*',
      group = NvimHeadbandWinbarMod.augroup,
      callback = get_headband_callback(NvimHeadbandWinbarMod),
    }
  )
end

function NvimHeadbandWinbarMod:clear_autocmd()
  api.nvim_clear_autocmds { group = self.augroup }
end

function NvimHeadbandWinbarMod:set_winbar_string()
  vim.wo.winbar = self.winbar_string
end

function NvimHeadbandWinbarMod:clear_winbar_string()
  for _, window in ipairs(api.nvim_list_wins()) do
    api.nvim_win_set_option(window, 'winbar', '')
  end
end

function NvimHeadbandWinbarMod:disable()
  if not self.config.enable then
    return
  else
    self.config.enable = false

    self:clear_winbar_string()
    self:clear_autocmd()
  end
end

function NvimHeadbandWinbarMod:enable()
  self.config.enable = true

  self:set_winbar_string()
  self:register_autocmd()
end

local Winbar = {}

Winbar.start = function(config)
  local augroup = function(x)
    return api.nvim_create_augroup(x, { clear = true })
  end

  NvimHeadbandWinbarMod.config = config
  NvimHeadbandWinbarMod.augroup = augroup('NvimHeadbandWinbar')
  NvimHeadbandWinbarMod.winbar_string = '%{%v:lua.NvimHeadbandWinbarMod.get()%}'

  NvimHeadbandWinbarMod:enable()
end

return Winbar
