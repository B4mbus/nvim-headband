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

return Utils
