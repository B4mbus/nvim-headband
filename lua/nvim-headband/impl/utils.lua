local Utils = {}

function Utils.conditional_require(name, handler)
  if package.preload[name] then
    return true, require(name)
  end

  local loaded, mod = xpcall(
    require,
    handler,
    name
  )

  return loaded, mod
end

--- Returns the return of a call or returns the object itself depdening if it's a function
---@param obj any Whatever object
function Utils.call_or_id(obj)
  if type(obj) == 'function' then
    return obj()
  else
    return obj
  end
end

Utils.empty_hl = '%##'

function Utils.hl(name)
  return '%#' .. name .. '#'
end

return Utils
