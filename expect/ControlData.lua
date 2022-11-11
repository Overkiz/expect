local FailureMessage = require('expect.FailureMessage')
local Utils = require('expect.Utils')

--- Metatable for the ControlData objects.
local ControlDataMT = {}

--- ControlData is an object provided to feature functions.
--- It contains miscellaneous data about the control being done, including `actual`, the real value being tested.
--- Usually, this kind of object is created through the Expect object and may not be used alone.
--- @class ControlData
--- @alias ControlData fun(data: ControlData|table)
--- @param data ControlData|table The data used to initialize object, will be shallow copied.
local ControlData = setmetatable({}, {
  __call = function(_, data)
    data = data or {}
    local controlData = {}
    for key, value in pairs(data) do
      controlData[key] = value
    end
    return setmetatable(controlData, ControlDataMT)
  end
})
ControlDataMT.__index = ControlData

--- Check if the actual object has the appropriate type.
--- @param expected string The expected type for the object.
--- @param checkNegation boolean|nil Indicate if negation (i.e. `not`) should be checked.
function ControlData:checkType(expected, checkNegation)
  expected = expected:lower()
  local params = {
    article = string.find('aeiou', expected:sub(1, 1)) and 'an' or 'a',
    expected = expected
  }
  self:assert(type(self.actual):lower() == expected,
    FailureMessage('expected {#} to be {!article} {!expected}', params),
    checkNegation and FailureMessage('expected {#} not to be {!article} {!expected}', params) or nil, 2)
end

--- Check if the actual object is callable.
--- @param checkNegation boolean|nil Indicate if negation (i.e. `not`) should be checked.
function ControlData:checkIfCallable(checkNegation)
  self:assert(Utils.isCallable(self.actual),
    FailureMessage('expected {#} to be callable'),
    checkNegation and FailureMessage('expected {#} not to be callable') or nil, 2)
end

--- Process an assertion on the control data.
--- @param expr boolean The expression to test, if false, an exception is thrown.
--- @param positiveMsg FailureMessage Failure message to display if test fails.
--- @param negativeMsg FailureMessage|nil Failure message to display if test succeed, but we want it to fail (using a `not`), nil to ignore negation.
--- @param level integer|nil The level of the error.
function ControlData:assert(expr, positiveMsg, negativeMsg, level)
  if expr and self.negate and negativeMsg then
    return self:fail(negativeMsg, (level or 1) + 1)
  elseif not (expr or (self.negate and negativeMsg)) then
    return self:fail(positiveMsg, (level or 1) + 1)
  end
end

--- Fail with a message.
--- @param message FailureMessage The failure message to display.
--- @param level integer|nil The level of the error.
function ControlData:fail(message, level)
  error('Not implemented') -- Implemented externally
end

return ControlData
