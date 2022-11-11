local Utils = {}

--- Check if the item is a callable (i.e. can be called like a function).
--- @param item any The item to check.
--- @return boolean
function Utils.isCallable(item)
  return type(item) == 'function' or (type(item) == 'table' and type((getmetatable(item) or {}).__call) == 'function')
end

--- Check if item can be considered an array. If true, return the maximum index of the array.
--- @param item any The item to check.
--- @return false|number
function Utils.isArray(item)
  if type(item) ~= 'table' then
    return false
  end

  local max = 0
  local count = 0
  for k, v in pairs(item) do
    if type(k) == 'number' then
      if k > max then
        max = k
      end
      count = count + 1
    else
      return false
    end
  end
  if max > count * 2 then
    return false
  end

  -- Maximum index
  return max
end

return Utils
