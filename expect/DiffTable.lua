--- The metatable used to identify DiffTable objects.
local DiffTableMT = {}

--- A DiffTable object is actually a table containing some highlighted items used to show differences with
--- another table.
--- @class DiffTable
--- @field initial table The initial table.
--- @field diffs table The differences.
--- @alias DiffTable fun(initial: any, diffs: table|nil)
--- @param initial any The initial object.
--- @param diffs table|nil The differences, if any.
local DiffTable = setmetatable({}, {
  __call = function(DiffTable, initial, diffs)
    if type(initial) == 'table' and not DiffTable.isInstance(initial) and diffs then
      return setmetatable({
        initial = initial,
        diffs = diffs
      }, DiffTableMT)
    else
      return initial
    end
  end
})

--- Indicate if the given item is an instance of DiffTable
--- @param time any The item to test.
--- @return boolean
function DiffTable.isInstance(item)
  return type(item) == 'table' and getmetatable(item) == DiffTableMT
end

--- Compare 2 objects, recursing into entries for tables.
--- @param item1 any The first object to compare.
--- @param item2 any The second object to compare.
--- @param cycles table A table to keep information on cycles.
--- @return boolean, table|nil
local function deepCompare(item1, item2, cycles)
  -- Non-table types can be directly compared
  if type(item1) ~= 'table' or type(item2) ~= 'table' then
    return item1 == item2
  end

  -- Check using metatable
  local mt1 = getmetatable(item1)
  local mt2 = getmetatable(item2)
  if mt1 and mt1 == mt2 and mt1.__eq then
    return item1 == item2
  elseif rawequal(item1, item2) then
    return true
  end

  -- Handle recursive tables
  cycles.item1[item1] = (cycles.item1[item1] or 0)
  cycles.item2[item2] = (cycles.item2[item2] or 0)
  if cycles.item1[item1] == 1 or cycles.item2[item2] == 1 then
    cycles.threshold1 = cycles.item1[item1] + 1
    cycles.threshold2 = cycles.item2[item2] + 1
  end
  if cycles.item1[item1] > cycles.threshold1 and cycles.item2[item2] > cycles.threshold2 then
    return true
  end

  cycles.threshold1 = cycles.item1[item1] + 1
  cycles.threshold2 = cycles.item2[item2] + 1

  -- Compare table content
  for k1, v1 in pairs(item1) do
    local v2 = item2[k1]
    if v2 == nil then
      return false, {k1}
    end
    local same, diffs = deepCompare(v1, v2, cycles)
    if not same then
      diffs = diffs or {}
      table.insert(diffs, k1)
      return false, diffs
    end
  end

  -- Check that there are no extra key in second table
  for k2 in pairs(item2) do
    if item1[k2] == nil then
      return false, {k2}
    end
  end

  cycles.item1[item1] = cycles.item1[item1] - 1
  cycles.item2[item2] = cycles.item2[item2] - 1

  return true
end

--- Compare 2 items which may, or may not, be tables. The result is the result of the comparison and the
--- items, as DiffTable objects if there are differences and if they are tables, unmodified otherwise.
--- @param item1 any The first object to compare.
--- @param item2 any The second object to compare.
--- @return boolean, any, any
function DiffTable.compare(item1, item2)
  local same, diffs = deepCompare(item1, item2, {
    item1 = {},
    item2 = {},
    threshold1 = 1,
    threshold2 = 1
  })
  return same, DiffTable(item1, diffs), DiffTable(item2, diffs)
end

return DiffTable
