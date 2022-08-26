local Utils = {}

--- Returns a @BufferFunc that filters out certain buffertypes
---@param buffer_types string[] The filetypes
---@return BufferFunc
Utils.bt_filter = function(buffer_types)
  --- Filters out certain buffertypes
  ---@type BufferFunc
  ---@param bid number Buffer id
  ---@param bname string Buffer name
  ---@param bt string Buftype
  ---@param ft string Filetype
  ---@return boolean
  return function(bid, bname, bt, ft)
    return vim.tbl_contains(buffer_types, bt)
  end
end

return Utils
