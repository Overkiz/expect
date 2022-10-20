local ControlData = require("expect.ControlData")

--- Expect is the main object seen by the end-user. It provides all features as properties or functions and, when
--- requested, call them providing ControlData.
--- @class Expect
--- @alias Expect fun(data: ControlData|table)
--- @param data ControlData|table The data used to create control data.
local Expect = setmetatable({}, {
  __call = function(Expect, data)
    local controlData = ControlData(data)
    return setmetatable({}, {
      __index = function(_, key)
        key = key:lower()
        return Expect.executeFeature(key, controlData)
      end
    })
  end
})

--- Execute the feature. Internal use only.
--- @param key string The feature name.
--- @param controlData ControlData The data.
function Expect.executeFeature(key, controlData)
  error("Not implemented") -- Implemented externally
end

return Expect
