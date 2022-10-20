local DiffTable = require('expect.DiffTable')
local FailureMessage = require('expect.FailureMessage')
local ControlData = require('expect.ControlData')
local Expect = require('expect.Expect')

--
-- Private functions
--

--- The global parameters used by assert.
local parameters = {
  throw = error,
  plugins = {}
}

--- The feature functions available for the tests.
local features = {}

--- A no-op function.
local function noop()
end

--
-- Overrides
--

--- Fail with a message.
--- @param message FailureMessage The failure message to display.
--- @param level integer|nil The level of the error.
function ControlData:fail(message, level)
  local message = tostring(message:setActual(self.actual))
  parameters.throw(self.message and (self.message .. ': ' .. message) or message, (level or 1) + 2)
end

--- Execute the feature.
--- @param key string The feature name.
--- @param controlData ControlData The data.
function Expect.executeFeature(key, controlData)
  if features[key] then
    return features[key](controlData)
  end
end

--
-- Definition of the expect object
--

--- This is the only exported object of the library. For the end-user, it is the expect() function, but for plugins, the
--- object also exports usefull objects and functions.
--- @class expect
--- @field parameters table The global parameters.
--- @alias expect fun(actual: any)
--- @alias expect fun(actual: any, message: string)
--- @param actual any The actual object to test.
--- @param message string An optional message to identify the test.
local expect = setmetatable({
  parameters = parameters
}, {
  __call = function(_, actual, message)
    return Expect({
      actual = actual,
      message = message
    })
  end
})

--- Add a feature.
--- @param name string The name of the feature to add.
--- @param featureFunc fun(data: ControlData) The feature function.
local function addFeature(name, featureFunc)
  name = name:lower()
  if features[name] then
    error('Plugin conflict: cannot set already existing feature ' .. name)
  end
  features[name] = featureFunc
end

--- Add a feature function seen as a property.
--- @param name string The name of the feature to add.
--- @param propertyFunction nil|fun(data: ControlData): any The property function. If nil, simply chain to next feature.
function expect.addProperty(name, propertyFunction)
  addFeature(name, function(controlData)
    local result = (propertyFunction or noop)(controlData)
    if result ~= nil then
      return result
    end
    return Expect(controlData)
  end)
end

--- Add a feature function seen as a method.
--- @param name string The name of the feature to add.
--- @param methodFunction nil|fun(data: ControlData, ...:any): any The method function. If nil, simply chain to next feature.
function expect.addMethod(name, methodFunction)
  addFeature(name, function(controlData)
    return function(...)
      local result = (methodFunction or noop)(controlData, ...)
      if result ~= nil then
        return result
      end
      return Expect(controlData)
    end
  end)
end

--- Add a feature function seen as both a property and a method.
--- @param name string The name of the feature to add.
--- @param methodFunction nil|fun(data: ControlData, ...:any): any The method function. If nil, simply chain to next feature.
--- @param propertyFunction nil|fun(data: ControlData): any The property function. If nil, simply chain to next feature.
function expect.addChainableMethod(name, methodFunction, propertyFunction)
  addFeature(name, function(controlData)
    local result = (propertyFunction or noop)(controlData)
    if result ~= nil then
      return result
    end
    result = Expect(controlData)
    getmetatable(result).__call = function(_, ...)
      local callingResult = (methodFunction or noop)(controlData, ...)
      if callingResult ~= nil then
        return callingResult
      end
      return Expect(controlData)
    end
    return result
  end)
end

--
-- Add the core plugin
--

--- Load the core feature functions
require('expect.core')(expect)

return expect
