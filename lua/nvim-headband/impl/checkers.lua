local Checkers = {}

Checkers.ensure = function (obj, target, ...)
  for _, type in ipairs({ ... }) do
    if type(obj) == type then
      return true
    end
  end

  return false
end

Checkers.concatenable = function(obj)
  return Checkers.ensure(obj, 'number', 'string')
end

return Checkers
