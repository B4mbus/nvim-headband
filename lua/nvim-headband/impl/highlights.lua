local Highlights = {}

Highlights.empty_hl = '%##'

Highlights.hl = function(name)
  return '%#' .. name .. '#'
end

return Highlights
