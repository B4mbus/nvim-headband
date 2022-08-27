local Utils = {}

Utils.conditional_require = function(name, handler)
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
Utils.call_or_id = function(obj)
  if type(obj) == 'function' then
    return obj()
  else
    return obj
  end
end

Utils.empty_hl = '%##'

Utils.hl = function(name)
  return '%#' .. name .. '#'
end

return Utils
