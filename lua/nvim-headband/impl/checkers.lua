local Checkers = {}

Checkers.ensure = function (obj, ...)
  for _, needed_type in ipairs({ ... }) do
    if type(obj) == needed_type then
      return true
    end
  end

  return false
end

Checkers.concatenable = function(obj)
  return Checkers.ensure(obj, 'number', 'string')
end

return Checkers
