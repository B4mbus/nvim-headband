local SectionShared = {}

local issue_wrap_concanetable_error = function(section)
  error(string.format('The wrap %s section must be concatenable.', section))
end

local empty_wrap_function = function(arg)
  return arg
end

local wrap_function = function(wrap_pre, wrap_post)
  return function(arg)
    return (wrap_pre or '') .. arg .. (wrap_post or '')
  end
end

SectionShared.evaluate_wrap = function(wrap)
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

  local Checkers = require 'nvim-headband.impl.checkers'
  if wrap_pre and not Checkers.concatenable(wrap_pre) then
    issue_wrap_concanetable_error('pre')
  end

  if wrap_post and not Checkers.concatenable(wrap_post) then
    issue_wrap_concanetable_error('post')
  end

  return wrap_function(wrap_pre, wrap_post)
end

return SectionShared
