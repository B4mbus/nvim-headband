local Filters = {}

--- Returns a @BufferFilterFunc that filters out certain buffertypes
---@param buffertypes string[] The buffertypes
---@return BufferFilterFunc
Filters.bt_filter = function(buffertypes)
  --- Filters out certain buffertypes
  ---@type BufferFilterFunc
  ---@param bid number Buffer id
  ---@param bname string Buffer name
  ---@param bt string Buftype
  ---@param ft string Filetype
  ---@param prev boolean The result of previous filter if used with a combinator
  ---@return boolean
  return function(bid, bname, bt, ft, prev)
    if not prev then return false end
    return vim.tbl_contains(buffertypes, bt)
  end
end

--- Returns a @BufferFilterFunc that filters out certain buffertypes
---@param filetypes string[] The filetypes
---@return BufferFilterFunc
Filters.ft_filter = function(filetypes)
  --- Filters out certain filetypes
  ---@type BufferFilterFunc
  ---@param bid number Buffer id
  ---@param bname string Buffer name
  ---@param bt string Buftype
  ---@param ft string Filetype
  ---@param prev boolean The result of previous filter if used with a combinator
  ---@return boolean
  return function(bid, bname, bt, ft, prev)
    if not prev then return false end
    return vim.tbl_contains(filetypes, ft)
  end
end

--- Returns a @BufferFilterFunc that filters out certain buffertypes
---@param bufnames string[] The buffer names
---@return BufferFilterFunc
Filters.bname_filter = function(bufnames)
  --- Filters out certain buffer names
  ---@type BufferFilterFunc
  ---@param bid number Buffer id
  ---@param bname string Buffer name
  ---@param bt string Buftype
  ---@param ft string Filetype
  ---@param prev boolean The result of previous filter if used with a combinator
  ---@return boolean
  return function(bid, bname, bt, ft, prev)
    if not prev then return false end
    return vim.tbl_contains(bufnames, bname)
  end
end

--- Returns a @BufferFilterFunc that runs certain filters right after another
---@vararg BufferFilterFunc The functions
---@return BufferFilterFunc
Filters.combine = function(...)
  local filters = { ... }

  --- Returns combined @BufferFilterFunc s
  ---@type BufferFilterFunc
  ---@param bid number Buffer id
  ---@param bname string Buffer name
  ---@param bt string Buftype
  ---@param ft string Filetype
  ---@param prev boolean The result of previous filter if used with a combinator
  ---@return boolean
  return function(bid, bname, bt, ft, prev)
    local prev_result = true
    for _, filter in ipairs(filters) do
      prev_result = filter(bid, bname, bt, ft, prev_result)
    end

    return prev_result
  end
end

return Filters
