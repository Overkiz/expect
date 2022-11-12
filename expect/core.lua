local DiffTable = require('expect.DiffTable')
local FailureMessage = require('expect.FailureMessage')
local Utils = require('expect.Utils')

return function(expect)
  -- Chainable words with no action
  for _, key in pairs({'also', 'and', 'at', 'be', 'been', 'but', 'does', 'has', 'have', 'is', 'that', 'to', 'with',
                       'which'}) do
    expect.addProperty(key)
  end

  -- Set negate flag, which inverts the meaning of all coming tests
  expect.addProperty('not', function(controlData)
    controlData.negate = true
  end)

  -- Set deep flag
  expect.addProperty('deep', function(controlData)
    controlData.deep = true
  end)

  -- Check object is of given type
  local function expectAn(controlData, expected)
    controlData:checkType(expected, true)
  end
  expect.addChainableMethod('a', expectAn)
  expect.addChainableMethod('an', expectAn)

  -- Check object contains given params
  local function expectInclude(controlData, content)
    local actualType = type(controlData.actual)
    local included = false
    local params = {
      deeply = '',
      expected = content
    }

    if actualType == 'string' then
      included = controlData.actual:find(tostring(content), nil, true) ~= nil
    elseif actualType == 'table' then
      local compareItems
      if controlData.deep then
        params.deeply = 'deeply '
      end
      for _, item in pairs(controlData.actual) do
        if controlData:areSame(item, content) then
          included = true
          break
        end
      end
      if not included and not Utils.isArray(controlData.actual) and type(content) == 'table' and
        not Utils.isArray(content) then
        -- Also check table content element
        included = true
        for key, value in pairs(content) do
          if not controlData:areSame(controlData.actual[key], value) then
            included = false
            break
          end
        end
      end
    else
      controlData:fail(FailureMessage('expected {#} to be a string or a table'))
    end

    controlData:assert(included, FailureMessage('expected {#} to {!deeply}include {expected}', params),
      FailureMessage('expected {#} to not {!deeply}include {expected}', params))
  end
  expect.addMethod('include', expectInclude)
  expect.addMethod('includes', expectInclude)
  expect.addMethod('contain', expectInclude)
  expect.addMethod('contains', expectInclude)

  -- Check object is truthy
  expect.addMethod('ok', function(controlData)
    controlData:assert(not not controlData.actual, FailureMessage('expected {#} to be truthy'),
      FailureMessage('expected {#} to be falsy'))
  end)

  -- Check object is true
  expect.addMethod('true', function(controlData)
    controlData:assert(controlData.actual == true, FailureMessage('expected {#} to be true'),
      FailureMessage('expected {#} to be false'))
  end)

  -- Check object is false
  expect.addMethod('false', function(controlData)
    controlData:assert(controlData.actual == false, FailureMessage('expected {#} to be false'),
      FailureMessage('expected {#} to be true'))
  end)

  -- Check object is nil
  expect.addMethod('nil', function(controlData)
    controlData:assert(controlData.actual == nil, FailureMessage('expected {#} to be nil'),
      FailureMessage('expected {#} not to be nil'))
  end)

  -- Check object is strictly or deeply equal to given value
  local function expectEqual(controlData, expected)
    if controlData.deep then
      local same, actualObject, expectedObject = DiffTable.compare(controlData.actual, expected)
      local params = {
        actual = actualObject,
        expected = expectedObject
      }
      controlData:assert(same, FailureMessage('expected {actual} to deeply equal {expected}', params),
        FailureMessage('expected {actual} to not deeply equal {expected}', params))
    else
      local params = {
        expected = expected
      }
      controlData:assert(controlData.actual == expected, FailureMessage('expected {#} to equal {expected}', params),
        FailureMessage('expected {#} to not equal {expected}', params))
    end
  end
  expect.addMethod('equal', expectEqual)
  expect.addMethod('equals', expectEqual)

  -- Check object matches given pattern
  local function expectMatch(controlData, pattern)
    local params = {
      pattern = pattern
    }
    controlData:assert(tostring(controlData.actual):match(pattern),
      FailureMessage('expected {#} to match {!pattern}', params),
      FailureMessage('expected {#} to not match {!pattern}', params))
  end
  expect.addMethod('match', expectMatch)
  expect.addMethod('matches', expectMatch)

  -- Check function throws an exception
  local function expectFail(controlData, expectedErr, plain)
    controlData:checkIfCallable()
    local ok, actualErr = pcall(controlData.actual)

    if not ok and type(actualErr) == 'string' then
      actualErr = actualErr:gsub('^.-:%d+: ', '', 1)
    end
    local expectedMsg = expectedErr == nil and '' or ' with error {expectedErr}'
    local actualMsg = actualErr == nil and '' or ', but {actualErr} was thrown'
    local params = {
      expectedErr = expectedErr,
      actualErr = actualErr
    }

    if ok or expectedErr == nil then
      controlData:assert(not ok, FailureMessage('expected {#} to fail, but it was successful'),
        FailureMessage('expected {#} not to fail' .. actualMsg, params))
    elseif type(expectedErr) == 'string' and
      (type(actualErr) == 'string' or type((getmetatable(actualErr) or {}).__tostring) == 'function') then
      controlData:assert(tostring(actualErr):find(expectedErr, 1, plain) ~= nil,
        FailureMessage('expected {#} to fail' .. expectedMsg .. actualMsg, params),
        FailureMessage('expected {#} not to fail' .. expectedMsg, params))
    elseif type(expectedErr) == 'number' and type(actualErr) == 'string' then
      controlData:assert(expectedErr == tonumber(actualErr),
        FailureMessage('expected {#} to fail' .. expectedMsg .. actualMsg, params),
        FailureMessage('expected {#} not to fail' .. expectedMsg, params))
    else
      local same, expectedErr, actualErr = DiffTable.compare(expectedErr, actualErr)
      params = {
        expectedErr = expectedErr,
        actualErr = actualErr
      }
      controlData:assert(same, FailureMessage('expected {#} to fail' .. expectedMsg .. actualMsg, params),
        FailureMessage('expected {#} not to fail' .. expectedMsg, params))
    end
  end
  expect.addMethod('fail', expectFail)
  expect.addMethod('fails', expectFail)
  expect.addMethod('error', expectFail)
  expect.addMethod('failWith', expectFail)
  expect.addMethod('failsWith', expectFail)
end
