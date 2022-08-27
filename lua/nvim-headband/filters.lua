local Filters = {}

--- Returns a @BufferFunc that filters out certain buffertypes
---@param buffertypes string[] The buffertypes
---@return BufferFunc
Filters.bt_filter = function(buffertypes)
  --- Filters out certain buffertypes
  ---@type BufferFunc
  ---@param bid number Buffer id
  ---@param bname string Buffer name
  ---@param bt string Buftype
  ---@param ft string Filetype
  ---@return boolean
  return function(bid, bname, bt, ft)
    return vim.tbl_contains(buffertypes, bt)
  end
end

--- Returns a @BufferFunc that filters out certain buffertypes
---@param filetypes string[] The filetypes
---@return BufferFunc
Filters.ft_filter = function(filetypes)
  --- Filters out certain filetypes
  ---@type BufferFunc
  ---@param bid number Buffer id
  ---@param bname string Buffer name
  ---@param bt string Buftype
  ---@param ft string Filetype
  ---@return boolean
  return function(bid, bname, bt, ft)
    return vim.tbl_contains(filetypes, ft)
  end
end

--- Returns a @BufferFunc that filters out certain buffertypes
---@param bufnames string[] The buffer names
---@return BufferFunc
Filters.bname_filter = function(bufnames)
  --- Filters out certain buffer names
  ---@type BufferFunc
  ---@param bid number Buffer id
  ---@param bname string Buffer name
  ---@param bt string Buftype
  ---@param ft string Filetype
  ---@return boolean
  return function(bid, bname, bt, ft)
    return vim.tbl_contains(bufnames, bname)
  end
end

return Filters
