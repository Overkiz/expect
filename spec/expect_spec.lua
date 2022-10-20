local expect = require('expect')

local EXISTING_FEATURES = {
  to = 'property',
  equal = 'method',
  a = 'chainable method'
}
local FEATURE_FUNCTIONS = {
  property = 'addProperty',
  method = 'addMethod',
  ['chainable method'] = 'addChainableMethod'
}
describe('expect', function()
  for name, category in pairs(EXISTING_FEATURES) do
    for addedCategory, featureFunction in pairs(FEATURE_FUNCTIONS) do
      it('should refuse addition of ' .. addedCategory .. ' “' .. name .. '” which has same name as existing ' ..
           category, function()
        expect(function()
          expect[featureFunction](name)
        end).to.failWith('Plugin conflict: cannot set already existing feature ' .. name:lower())
      end)

      it('should refuse addition of ' .. addedCategory .. ' “' .. name:upper() ..
           '” conflicting with already existing ' .. category .. ' “' .. name .. '”', function()
        expect(function()
          expect[featureFunction](name)
        end).to.failWith('Plugin conflict: cannot set already existing feature ' .. name:lower())
      end)
    end
  end
end)
