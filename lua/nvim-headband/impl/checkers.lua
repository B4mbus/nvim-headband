local Checkers = {}

function Checkers.ensure(obj, ...)
  for _, needed_type in ipairs({ ... }) do
    if type(obj) == needed_type then
      return true
    end
  end

  return false
end

function Checkers.concatenable(obj)
  return Checkers.ensure(obj, 'number', 'string')
end

return Checkers
