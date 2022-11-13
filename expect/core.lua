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

  -- Set any flag
  expect.addProperty('any', function(controlData)
    controlData.any = true
  end)

  -- Set all flag
  expect.addProperty('all', function(controlData)
    controlData.any = false
  end)

  -- Check object is of given type
  local function expectAn(controlData, expected)
    controlData:checkType(expected, true)
  end
  expect.addChainableMethod('a', expectAn)
  expect.addChainableMethod('an', expectAn)

  -- Check object contains given params
  local function expectIncludeChain(controlData)
    controlData.previousContains = controlData.contains
    controlData.contains = true
  end
  local function expectInclude(controlData, content)
    controlData.contains = controlData.previousContains

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
  expect.addChainableMethod('include', expectInclude, expectIncludeChain)
  expect.addChainableMethod('includes', expectInclude, expectIncludeChain)
  expect.addChainableMethod('contain', expectInclude, expectIncludeChain)
  expect.addChainableMethod('contains', expectInclude, expectIncludeChain)

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

  -- Check object is empty
  expect.addMethod('empty', function(controlData)
    local actualType = type(controlData.actual)
    local empty = false
    if actualType == 'string' then
      empty = controlData.actual:len() == 0
    elseif actualType == 'table' then
      empty = next(controlData.actual) == nil
    else
      controlData:fail(FailureMessage('expected {#} to be a string or a table'))
    end

    controlData:assert(empty, FailureMessage('expected {#} to be empty'), FailureMessage('expected {#} not to be empty'))
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

  -- Check object is above value
  local function expectAbove(controlData, expected)
    local params = {
      expected = expected
    }
    if controlData.doLength then
      params.actual = controlData:getLength()
      controlData:assert(params.actual > expected,
        FailureMessage('expected {#} to have a length above {!expected} but got {!actual}', params),
        FailureMessage('expected {#} to not have a length above {!expected}', params))
    else
      controlData:checkType('number', false)
      controlData:assert(controlData.actual > expected, FailureMessage('expected {#} to be above {!expected}', params),
        FailureMessage('expected {#} to be at most {!expected}', params))
    end
  end
  expect.addMethod('above', expectAbove)
  expect.addMethod('gt', expectAbove)
  expect.addMethod('greaterThan', expectAbove)

  -- Check object is at least value
  local function expectLeast(controlData, expected)
    local params = {
      expected = expected
    }
    if controlData.doLength then
      params.actual = controlData:getLength()
      controlData:assert(params.actual >= expected, FailureMessage(
        'expected {#} to have a length of at least {!expected} but got {!actual}', params),
        FailureMessage('expected {#} to have a length below {!expected}', params))
    else
      controlData:checkType('number', false)
      controlData:assert(controlData.actual >= expected,
        FailureMessage('expected {#} to be at least {!expected}', params),
        FailureMessage('expected {#} to be below {!expected}', params))
    end
  end
  expect.addMethod('least', expectLeast)
  expect.addMethod('gte', expectLeast)
  expect.addMethod('greaterThanOrEqual', expectLeast)

  -- Check object is below value
  local function expectBelow(controlData, expected)
    local params = {
      expected = expected
    }
    if controlData.doLength then
      params.actual = controlData:getLength()
      controlData:assert(params.actual < expected,
        FailureMessage('expected {#} to have a length below {!expected} but got {!actual}', params),
        FailureMessage('expected {#} to not have a length below {!expected}', params))
    else
      controlData:checkType('number', false)
      controlData:assert(controlData.actual < expected, FailureMessage('expected {#} to be below {!expected}', params),
        FailureMessage('expected {#} to be at least {!expected}', params))
    end
  end
  expect.addMethod('below', expectBelow)
  expect.addMethod('lt', expectBelow)
  expect.addMethod('lessThan', expectBelow)

  -- Check object is at most value
  local function expectMost(controlData, expected)
    local params = {
      expected = expected
    }
    if controlData.doLength then
      params.actual = controlData:getLength()
      controlData:assert(params.actual <= expected, FailureMessage(
        'expected {#} to have a length of at most {!expected} but got {!actual}', params),
        FailureMessage('expected {#} to have a length above {!expected}', params))
    else
      controlData:checkType('number', false)
      controlData:assert(controlData.actual <= expected,
        FailureMessage('expected {#} to be at most {!expected}', params),
        FailureMessage('expected {#} to be above {!expected}', params))
    end
  end
  expect.addMethod('most', expectMost)
  expect.addMethod('lte', expectMost)
  expect.addMethod('lessThanOrEqual', expectMost)

  -- Check object is within values
  expect.addMethod('within', function(controlData, low, high)
    local params = {
      low = low,
      high = high
    }
    if controlData.doLength then
      local length = controlData:getLength()
      controlData:assert(length >= low and length <= high,
        FailureMessage('expected {#} to have a length within {!low}..{!high}', params),
        FailureMessage('expected {#} to not have a length within {!low}..{!high}', params))
    else
      controlData:checkType('number', false)
      controlData:assert(controlData.actual >= low and controlData.actual <= high,
        FailureMessage('expected {#} to be within {!low}..{!high}', params),
        FailureMessage('expected {#} to not be within {!low}..{!high}', params))
    end
  end)

  -- Check object property
  expect.addMethod('property', function(controlData, name, value)
    controlData:checkType('table', false)

    local params = {
      name = name
    }
    local propertyValue = controlData.actual[name]

    if not controlData.negate or value == nil then
      controlData:assert(propertyValue ~= nil, FailureMessage('expected {#} to have property {!name}', params),
        FailureMessage('expected {#} to not have property {!name}', params))
    end

    if value ~= nil then
      local same, expected, actual = controlData:areSame(value, propertyValue)
      params.deep = controlData.deep and 'deep ' or ''
      params.expected = expected
      params.actual = actual
      controlData:assert(same, FailureMessage(
        'expected {#} to have {!deep}property {!name} of {expected} but got {actual}', params),
        FailureMessage('expected {#} to not have {!deep}property {!name} of {actual}', params))
    end

    controlData.actual = propertyValue
  end)

  -- Check object length
  local function expectLengthChain(controlData)
    controlData.previousDoLength = controlData.doLength
    controlData.doLength = true
  end
  local function expectLength(controlData, expected)
    controlData.doLength = controlData.previousDoLength

    local length = controlData:getLength()
    local params = {
      expected = expected,
      length = length
    }
    controlData:assert(length == expected,
      FailureMessage('expected {#} to have a length of {!expected} but got {!length}', params),
      FailureMessage('expected {#} to not have a length of {!expected}', params))
  end
  expect.addChainableMethod('length', expectLength, expectLengthChain);
  expect.addChainableMethod('lengthOf', expectLength, expectLengthChain);

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

  -- Check object has keys
  local function expectKeys(controlData, ...)
    controlData:checkType('table', false)

    local expected = {...}
    local ok = false

    if controlData.any then
      for _, expectedItem in pairs(expected) do
        for key in pairs(controlData.actual) do
          if controlData:areSame(expectedItem, key) then
            ok = true
            break
          end
        end
        if ok then
          break
        end
      end
    else
      -- All
      ok = true
      for _, expectedItem in pairs(expected) do
        ok = false
        for key in pairs(controlData.actual) do
          if controlData:areSame(expectedItem, key) then
            ok = true
            break
          end
        end
        if not ok then
          break
        end
      end

      -- Not contains = same key count
      if ok and not controlData.contains then
        local count = 0
        for _ in pairs(controlData.actual) do
          count = count + 1
        end
        ok = count == #expected
      end
    end

    -- Prepare to display keys
    setmetatable(expected, {
      __tostring = function()
        local result = 'key'
        if #expected > 1 then
          result = result .. 's '
          for i = 1, #expected do
            if i == #expected then
              result = result .. (controlData.any and ' or ' or ' and ')
            elseif i > 1 then
              result = result .. ', '
            end
            result = result .. tostring(expected[i])
          end
        else
          result = result .. ' ' .. tostring(expected[1])
        end
        return result
      end
    })

    local params = {
      keys = expected,
      deeply = controlData.deep and 'deeply ' or '',
      possess = controlData.contains and 'contain' or 'have'
    }
    controlData:assert(ok, FailureMessage('expected {#} to {!deeply}{!possess} {!keys}', params),
      FailureMessage('expected {#} to not {!deeply}{!possess} {!keys}', params))
  end
  expect.addMethod('keys', expectKeys)
  expect.addMethod('key', expectKeys)

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

  -- Check target satisfies a function
  local function expectSatisfy(controlData, matcher)
    local params = {
      matcher = matcher
    }
    controlData:assert(matcher(controlData.actual), FailureMessage('expect {#} to satisfy {matcher}', params),
      FailureMessage('expect {#} to not satisfy {matcher}', params))
  end
  expect.addMethod('satisfy', expectSatisfy)
  expect.addMethod('satisfies', expectSatisfy)

  -- Check target is close to expected
  local function expectCloseTo(controlData, expected, delta)
    controlData:checkType('number', false)
    local params = {
      expected = expected,
      delta = delta
    }

    controlData:assert(math.abs(controlData.actual - expected) <= delta,
      FailureMessage('expected {#} to be close to {!expected} +/- {!delta}', params),
      FailureMessage('expected {#} not to be close to {!expected} +/- {!delta}', params))
  end
  expect.addMethod('closeTo', expectCloseTo)
  expect.addMethod('approximately', expectCloseTo)
end
