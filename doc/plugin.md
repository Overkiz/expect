It is rather easy to write plugins in order to extend the capabilities of `expect`. Anyway, `expect` will
prevent from adding the same feature several times, so plugin writers must carefully choose the name of the
features. Remember that features are case-insensitive, so you cannot add an `equal` feature, neither can you
add an `Equal` one.

# Example

The [core.lua](../expect/core.lua) file itself is a plugin containing the core features. You can use it as an
example to see how a plugin should be written.

# Basic

Your plugin should return a function taking `expect` as a single parameter. The function will add the
features (assertions) to `expect`. You can add diffent kinds of features:

- properties, using `expect.addProperty(name[, fun])`, will add a feature callable as a property; you may do
assertions in it, but remember that it is an error to terminate a statement with a property in LUA, so it is
better to either do nothing (chainable word) or set a control data property;
- methods, using `expect.addMethod(name[, fun])`, will add a feature callable as a method, which may take
some parameters;
- mixed, using `expect.addChainableMethod(name[, fun[, fun]])`, will add a feature callable both as a method
(first provided callback) and as a property (second callback); both calls can have an action, but beware that
the action executed for the property usage is also executed when the feature is called as a method.

If you don’t provide callbacks when using these functions, a no-op one will be used.

```lua
local FailureMessage = require('expect.FailureMessage')

return function(expect)
  -- Add a no-op property (chaining word)
  expect.addProperty('whatever')

  -- Add a property setting a flag on control data
  expect.addProperty('fluffy', function(controlData)
    controlData.fluffy = true
  end)

  -- Add a method with a size parameter
  expect.addMethod('longerThan', function(controlData, size)
    controlData:checkType("string") -- Only applies to strings
    if controlData.fluffy then -- See if this flag was previously set
      size = size * 2
    end
    local params = { -- Prepare parameters for failure messages
      size = size
    }
    controlData:assert(controlData.actual:len() > size, FailureMessage('expected {#} to be longer than {size}', params),
      FailureMessage('expected {#} to not be longer than {size}', params))
  end)

  -- Add a mixed feature
  expect.addChainableMethod('theAnswerToLifeUniverseAndEverything', function(controlData)
    controlData:assert(controlData.actual == 42, FailureMessage('expected {#} to be 42'),
      FailureMessage('expected {#} to not be 42'))
  end, function(controlData)
    controlData.answer = 42
  end)
end
```

All this may be used this way:

```lua
expect("a long string").to.be.fluffy.And.theAnswerToLifeUniverseAndEverything.but.longerThan(3)
expect(42).to.whatever.be.theAnswerToLifeUniverseAndEverything()
```

# API

## ControlData

The first parameter provided to a feature function is a `ControlData` object. This object can contain any
data needed for the assertion. The object is shallow-copied between each chained feature. If you add your own
property to this object, be careful to choose the name in order to prevent conflicts with other plugins.

To create a `ControlData` object, simply call `ControlData(data)` where `data` is either a table or a
`ControlData` object which will be shallow-copied. But you probably do not need to directly create a
`ControlData` object, this kind of object is usually created through the `Expect` object.

Not counting plugin additions, the `ControlData` object contains the following properties and functions:

### actual

This is the actual object being tested. Usually, this is the one provided to the `expect` function as first
parameter, but this can be modified by a feature.

### negate

This property is set to true if the user called the `not` feature earlier in the assertion. It can be either
`nil` or `false` otherwise.

### checkType(expected[, checkNegation])

You may call this function to ensure that actual object is of appropriate type. If `checkNegation` is `true`,
then the check will be inverted if the assertion is negated. The function does not return any value but fails
if the type is not of expected type.

### checkIfCallable([checkNegation])

This function can be used to ensure that the actual object is callable, i.e. either a function or a table
with a metatable defining a `__call` function. If `checkNegation` is `true`, then the check will be inverted
if the assertion is negated. The function does not return any value but fails if the actual object is not
callable.

### assert(expr, positiveMsg[, negativeMsg[, level]])

Call this function to process your assertion. If a `negativeMsg` is provided (not `nil`), then the function
will check if the assertion is negated and invert its behavior accordingly. Otherwise, the function fails if
`expr` is false.

- `positiveMsg` is the message to display (`FailureMessage`) if `expr` is false and the assertion is not
inverted;
- `negativeMsg` is the message to display (`FailureMessage`) if `expr` is true and the assertion is inverted;
- `level` is a the level of functions to be ignored when throwing the error in order to show the real source
of the error; you usually should not need to set it.

### fail(message[, level])

This function make the assertion fail immediately, displaying the provided `message` (`FailureMessage`). The
`level` parameter is the level of functions to be ignored when throwing the error in order to show the real
source of the error; you usually should not need to set it.

## Expect

The `Expect` object is the one created by the `expect()` function and all consecutive features called. This
object does not contain any accessible data by itself, but it creates the `ControlData` object used when
calling the features, and it redirects every property request to the appropriate feature.

An `Expect` object can be created by calling `Expect(data)`, where `data` is given to `ControlData`
constructor.

## FailureMessage

A `FailureMessage` object is used to provide a message composed of a pattern and parameters. The message will
only be constructed before being used, which prevent loosing time creating an unneeded string. Parameters may
be formatted, depending on the pattern, in order to be clearly readable by the end-user.

To create a `FailureMessage` object, call `FailureMessage(pattern, parameters)` where `pattern` is the
pattern and `parameters` is a table containing the parameters: keys are the parameter names and values are
the values to show to end user. If a parameter is referenced in the pattern but is not in the `parameters`
table it will not be considered empty but `nil` (displayed as `(nil)`).

The pattern is a string containing placeholders for the parameters in the format `{name}` where `name` is the
name of the parameter. This name should only be made of letters, bad things may happen otherwise.

You do not need to provide `actual` to the parameters, it will be automatically added and can be displayed in
the message using the placeholder `{#}`.

If you want to add content without formatting, you can add use the format `{!name}` for the placeholder. The
parameter `name` will then be displayed using a simple `tostring` and no complex formatting.

Your pattern must not contain opening curly brace `{` except to indicate the start of a placeholder. If you
need to display an opening curly brace, add an empty placeholder `{}`.

### FailureMessage:setActual(actual)

This function is used internally to set the value of `actual`. You usually do not need to call it yourself.

### FailureMessage:toString()

This function is used internally to create the displayed message from the pattern and the parameters. This
function is called when calling `tostring(msg)` with a `FailureMessage` object.

## DiffTable

Objects of type `DiffTable` are containing an `initial` table and a `diffs` array to identify differences
with another table. To create a `DiffTable`, simply call `DiffTable(initial, diffs)`, but you usually should
not need to create such object as it is created automatically when comparing tables.

A `DiffTable` object can be directly provided as a `FailureMessage` parameter and will be displayed with the
differences highlighted.

### DiffTable.isInstance(item)

This function can be called on any object in order to check if this object is a `DiffTable` object. The
result is `true` if it is the case, `false` otherwise.

### DiffTable.compare(item1, item2)

This function compares the two provided items. If they are tables, they will be deep compared. The result of
the comparison is a boolean (`true` if objects are same) and either a copy of each object or a `DiffTable`
instead of each object if it makes sense.
