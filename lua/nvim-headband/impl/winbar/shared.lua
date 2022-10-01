 local Highlights = require('nvim-headband.impl.highlights')

local SectionShared = {}

local function issue_wrap_concanetable_error(section)
  error(string.format('The wrap %s section must be concatenable.', section))
end

local empty_wrap_function = function(arg)
  return arg
end

local function wrap_function(wrap_pre, wrap_post)
  return function(arg)
    return (wrap_pre or '') .. arg .. (wrap_post or '')
  end
end

local function create_and_activate_hl_definition(original_name, patched_name, bg, keep_foreground)
  local original_hl_def = Highlights.highlight_definition(original_name)

  original_hl_def.background = bg

  if not keep_foreground then
    original_hl_def = Highlights.remove_fg_from_definiton(original_hl_def)
  end

  vim.api.nvim_set_hl(0, patched_name, original_hl_def)
end

function SectionShared.create_wrapper(wrap)
  if not wrap then
    return empty_wrap_function
  end

  local wrap_pre
  local wrap_post
  if type(wrap) == 'function' then
    wrap_pre, wrap_post = wrap()
  else
    wrap_pre, wrap_post = wrap[1], wrap[2]
  end

  local Checkers = require('nvim-headband.impl.checkers')
  if wrap_pre and not Checkers.concatenable(wrap_pre) then
    issue_wrap_concanetable_error('pre')
  end

  if wrap_post and not Checkers.concatenable(wrap_post) then
    issue_wrap_concanetable_error('post')
  end

  return wrap_function(wrap_pre, wrap_post)
end

function SectionShared.create_local_patched_hl(original_name, bg, keep_foreground)
  local patched_name = 'NvimHeadband' .. original_name .. 'Patched'

  if not Highlights.hl_exists(patched_name) then
    create_and_activate_hl_definition(
      original_name,
      patched_name,
      bg,
      keep_foreground
    )
  end

  return patched_name
end

return SectionShared
