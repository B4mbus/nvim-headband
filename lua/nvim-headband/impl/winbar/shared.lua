local SectionShared = {}

local issue_wrap_concanetable_error = function(section)
  error(string.format('The wrap %s section must be concatenable.', section))
end

SectionShared.evaluate_wrap = function(wrap)
  local Checkers = require 'nvim-headband.impl.checkers'

  local wrap_pre
  local wrap_post
  if type(wrap) == 'function' then
    wrap_pre, wrap_post = wrap()
  else
    wrap_pre, wrap_post = wrap[1], wrap[2]
  end

  if wrap_pre or not Checkers.concatenable(wrap_pre) then
    issue_wrap_concanetable_error('pre')
  end

  if wrap_post or not Checkers.concatenable(wrap_post) then
    issue_wrap_concanetable_error('post')
  end

  return function(arg)
    return (wrap_pre or '') .. arg .. (wrap_post or '')
  end
end

return SectionShared
