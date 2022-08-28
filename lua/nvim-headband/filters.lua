local Filters = {}

--- Returns a @WinFilterFunc that filters out certain buffertypes
---@param buffertypes string[] The buffertypes
---@return WinFilterFunc
function Filters.bt_filter(buffertypes)
  --- Filters out certain buffertypes
  ---@type WinFilterFunc
  ---@param bid number Buffer id
  ---@param bname string Buffer name
  ---@param bt string Buftype
  ---@param ft string Filetype
  ---@param prev boolean The result of previous filter if used with a combinator
  ---@return boolean
  return function(bid, bname, bt, ft, prev)
    return prev or vim.tbl_contains(buffertypes, bt)
  end
end

--- Returns a @WinFilterFunc that filters out certain buffertypes
---@param filetypes string[] The filetypes
---@return WinFilterFunc
function Filters.ft_filter(filetypes)
  --- Filters out certain filetypes
  ---@type WinFilterFunc
  ---@param bid number Buffer id
  ---@param bname string Buffer name
  ---@param bt string Buftype
  ---@param ft string Filetype
  ---@param prev boolean The result of previous filter if used with a combinator
  ---@return boolean
  return function(bid, bname, bt, ft, prev)
    return prev or vim.tbl_contains(filetypes, ft)
  end
end

--- Returns a @WinFilterFunc that filters out certain buffertypes
---@param bufnames string[] The buffer names
---@return WinFilterFunc
function Filters.bname_filter(bufnames)
  --- Filters out certain buffer names
  ---@type WinFilterFunc
  ---@param bid number Buffer id
  ---@param bname string Buffer name
  ---@param bt string Buftype
  ---@param ft string Filetype
  ---@param prev boolean The result of previous filter if used with a combinator
  ---@return boolean
  return function(bid, bname, bt, ft, prev)
    return prev or vim.tbl_contains(bufnames, bname)
  end
end

--- Returns a @WinFilterFunc that runs certain filters right after another
---@vararg WinFilterFunc The functions
---@return WinFilterFunc
function Filters.combine(...)
  local filters = { ... }

  --- Returns combined @WinFilterFunc s
  ---@type WinFilterFunc
  ---@param bid number Buffer id
  ---@param bname string Buffer name
  ---@param bt string Buftype
  ---@param ft string Filetype
  ---@param prev boolean The result of previous filter if used with a combinator
  ---@return boolean
  return function(bid, bname, bt, ft, prev)
    local prev = prev or false

    for _, filter in ipairs(filters) do
      prev = filter(bid, bname, bt, ft, prev)
    end

    return prev
  end
end

--- Returns a @WinFilterFunc that runs certain filters right after another and immediately returns if any of them returns false
---@vararg WinFilterFunc The functions
---@return WinFilterFunc
function Filters.strict_combine(...)
  local filters = { ... }

  --- Returns combined @WinFilterFunc s
  ---@type WinFilterFunc
  ---@param bid number Buffer id
  ---@param bname string Buffer name
  ---@param bt string Buftype
  ---@param ft string Filetype
  ---@param prev boolean The result of previous filter if used with a combinator
  ---@return boolean
  return function(bid, bname, bt, ft, prev)
    local prev = prev or false

    for _, filter in ipairs(filters) do
      prev = filter(bid, bname, bt, ft, prev)

      if prev then
        return true
      end
    end

    return false
  end
end

return Filters
