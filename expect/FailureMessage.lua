local DiffTable = require('expect.DiffTable')

--- Function used to show differences in red, if possible.
local color
do
  local ok, term = pcall(require, 'term')
  local isatty = io.type(io.stdout) == 'file' and ok and term.isatty(io.stdout)
  if not isatty then
    local isWindows = package.config:sub(1, 1) == '\\'
    if isWindows and os.getenv('ANSICON') then
      isatty = true
    end
  end

  color = function(c)
    if isatty then
      return term.colors.red(c)
    else
      return c
    end
  end
end

--- Priority of key types when ordering tables.
local type_priorities = {
  number = 1,
  boolean = 2,
  string = 3,
  table = 4,
  ['function'] = 5,
  userdata = 6,
  thread = 7
}

--- Indicate if key is in the array part of the table.
--- @param key any The key to check.
--- @param length number The length of the table.
--- @return boolean
local function is_in_array_part(key, length)
  return type(key) == 'number' and 1 <= key and key <= length and math.floor(key) == key
end

--- Get the key of the table, sorted.
--- @param t table The table to sort.
--- @return table, number
local function get_sorted_keys(t)
  local keys = {}
  local nkeys = 0

  for key in pairs(t) do
    nkeys = nkeys + 1
    keys[nkeys] = key
  end

  local length = #t

  local function key_comparator(key1, key2)
    local type1, type2 = type(key1), type(key2)
    local priority1 = is_in_array_part(key1, length) and 0 or type_priorities[type1] or 8
    local priority2 = is_in_array_part(key2, length) and 0 or type_priorities[type2] or 8

    if priority1 == priority2 then
      if type1 == 'string' or type1 == 'number' then
        return key1 < key2
      elseif type1 == 'boolean' then
        return key1 -- put true before false
      end
    else
      return priority1 < priority2
    end
  end

  table.sort(keys, key_comparator)
  return keys, nkeys
end

--- The maximum depth to show a table.
local FORMAT_TABLE_MAX_DEPTH = 3

--- Format the provided table.
--- @param arg table The table to format.
--- @return string
local function format_table(arg)
  local diffs = {}
  if DiffTable.isInstance(arg) then
    diffs = arg.diffs
    arg = arg.initial
  end

  local type_desc
  if getmetatable(arg) == nil then
    type_desc = '(' .. tostring(arg) .. ') '
  elseif not pcall(setmetatable, arg, getmetatable(arg)) then
    -- cannot set same metatable, so it is protected, skip id
    type_desc = '(table) '
  else
    -- unprotected metatable, temporary remove the mt
    local mt = getmetatable(arg)
    setmetatable(arg, nil)
    type_desc = '(' .. tostring(arg) .. ') '
    setmetatable(arg, mt)
  end

  local cache = {}
  local function ft(t, l, with_diffs)
    if cache[t] and cache[t] > 0 then
      return '{ ... recursive }'
    end

    if next(t) == nil then
      return '{ }'
    end

    if l > math.max(FORMAT_TABLE_MAX_DEPTH, with_diffs and #diffs or 0) then
      return '{ ... more }'
    end

    local result = '{'
    local keys, nkeys = get_sorted_keys(t)

    cache[t] = (cache[t] or 0) + 1
    local diff = diffs[#diffs - l + 1]

    for i = 1, nkeys do
      local k = keys[i]
      local v = t[k]
      local use_diffs = with_diffs and k == diff

      if type(v) == 'table' then
        v = ft(v, l + 1, use_diffs)
      elseif type(v) == 'string' then
        v = '\'' .. v .. '\''
      end

      local ch = use_diffs and '*' or ''
      local indent = string.rep(' ', l * 2 - ch:len())
      local mark = (ch:len() == 0 and '' or color(ch))
      result = result .. string.format('\n%s%s[%s] = %s', indent, mark, tostring(k), tostring(v))
    end

    cache[t] = cache[t] - 1

    return result .. ' }'
  end

  return type_desc .. ft(arg, 1, true)
end

--- Format the provided boolean value.
--- @param arg boolean The boolean value to format.
--- @return string
local function format_boolean(arg)
  return string.format('(boolean) %s', tostring(arg))
end

--- Format the provided function.
--- @param arg fun(...: any): any The function to format.
--- @return string
local function format_function(arg)
  local debug_info = debug.getinfo(arg)
  return string.format('%s @ line %s in %s', tostring(arg), tostring(debug_info.linedefined),
    tostring(debug_info.source))
end

--- Format a nil value.
--- @return string
local function format_nil()
  return '(nil)'
end

--- Format a number.
--- @param arg number The number to format.
--- @return string
local function format_number(arg)
  local str
  if arg ~= arg then
    str = 'NaN'
  elseif arg == 1 / 0 then
    str = 'Inf'
  elseif arg == -1 / 0 then
    str = '-Inf'
  else
    str = string.format('%.20g', arg)
    if math.type and math.type(arg) == 'float' and not str:find('[%.,]') then
      str = str:gsub('%d+', '%0.0', 1)
    end
  end
  return string.format('(number) %s', str)
end

--- Format any type using `tostring`.
--- @param arg any The item to format.
--- @return string
local function format_simple(arg)
  return string.format('(%s) \'%s\'', type(arg), tostring(arg))
end

--- Formatter used for each type.
local formatters = {
  boolean = format_boolean,
  ['function'] = format_function,
  ['nil'] = format_nil,
  number = format_number,
  table = format_table
}

--- Format the given parameter.
--- @param arg any The parameter to format.
--- @return string The formatted parameter.
local function formatParameter(arg)
  local formatter = formatters[type(arg)]
  return type(formatter) == 'function' and formatter(arg) or format_simple(arg)
end

--- Metatable for the FailureMessage objects.
local FailureMessageMT = {}

--- A failure message is composed of a pattern, containing some placeholder in the form {name}, where the name
--- is a key which should be found in the parameters table. If name is not in the parameters, it will be
--- considered nil, and not empty! The placeholder may also be in the form {!name}. In this case, the value
--- for the name should be a string and will be inserted in the pattern without formatting. In order to safely
--- insert a curly brace in the pattern, it can be escaped using an empty {} which will be converted into an
--- opening curly brace. The value for actual is specific and should be identified as {#}.
--- @class FailureMessage
--- @alias FailureMessage fun(pattern: string, parameters: table)
--- @param pattern string The pattern of the message.
--- @param parameters table The parameters for the message.
local FailureMessage = setmetatable({}, {
  __call = function(_, pattern, parameters)
    return setmetatable({
      pattern = pattern or '',
      parameters = parameters or {}
    }, FailureMessageMT)
  end
})

--- Set the actual value.
--- @param actual any The actual value.
--- @return FailureMessage
function FailureMessage:setActual(actual)
  self.parameters['#'] = actual
  return self
end

--- Convert the object into a string.
--- @return string
function FailureMessage:toString()
  return self.pattern:gsub('{([^{}]*)}', function(name)
    if name:len() == 0 then
      return '{'
    end

    local raw = name:sub(1, 1)
    if raw == '!' then
      name = name:sub(2)
    else
      raw = nil
    end

    if raw then
      return tostring(self.parameters[name])
    else
      return formatParameter(self.parameters[name])
    end
  end)
end

--- Metatable content.
FailureMessageMT.__tostring = FailureMessage.toString
FailureMessageMT.__index = FailureMessage

return FailureMessage
