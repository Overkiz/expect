# Basic usage

An expect test always starts by calling `expect` with the target (tested object) and terminates by a function
call. You can apply more than one test at once to the target. Assertions are written in natural language.

```lua
local result = 21 * 2
expect(result).to.be.a("number").that.equals(42)
```

You can also write arbitrary message to prepend to any failed assertion that might occur.

```lua
local answer = 43;

-- expected (number) 43 to equal (number) 42
expect(answer).to.equal(42);

-- topic [answer]: expected (number) 43 to equal (number) 42
expect(answer, 'topic [answer]').to.equal(42);
```

All words after the `expect()` call are case-insensitive. This is useful for words which are reserved in LUA,
like `and` or `not`, which you can then write, for example, `And` or `Not`.

## Language chains

The following are chainable words (properties) to improve the readablity of your assertions:

- also
- and
- at
- be
- been
- but
- does
- has
- have
- is
- that
- to
- with
- which

## not

Negates all assertions that follow in the chain.

```lua
expect(function() end).to.Not.fail()
```

## deep

Used to do deep comparison instead of strict ones.

```lua
expect({a = 1}).to.deep.equal({a = 1})
```

## a(type)

Asserts that the target’s type is equal to the given string type. Types are case insensitive.

```lua
expect(12).to.be.a('number')
expect('foo').to.be.a('string')
```

The alias `.an` can be used interchangeably with `.a`.

## equal(value)

Asserts that the target is strictly or deeply (if `deep` is used earlier in the chain) equal to the given
value.

```lua
expect(6 + 6).to.equal(12)
expect('foo').to.equal('foo')
expect({}).to.Not.equal({})
expect({}).to.deep.equal({})
```

The alias `.equals` can be used interchangeably with `.equal`.

## fail([err[, plain]])

When no arguments are provided, `.fail` invokes the target function and asserts that an error is thrown.

```lua
expect(function() error("Failing") end).to.fail()
```

When one argument is provided, `.fail` invokes the target function and asserts that an error is thrown,
mathing the given argument. If this argument is of type string, the test is made using LUA function `find`
and a second boolean argument can be provided in order to consider the `err` as a plain string instead of a 
LUA pattern.

```lua
expect(function() error("Failing") end).to.failWith('Failing$')
expect(function() error("Failing") end).to.failWith('Fail', true)
```

Aliases `fails`, `error`, `failWith`, `failsWith` can be used interchangeably with `.fail`.

## false()

Asserts that the target is false.

```lua
expect(false).to.be.False()
```

## match(pattern)

Asserts that the target matches the given pattern.

```lua
expect('foo').to.match('^f.o$')
```

## nil()

Asserts that the target is nil.

```lua
expect(nil).to.be.Nil()
```

## ok()

Asserts that the target is truthy (i.e. neither `nil` nor `false`).

```lua
expect("foo").to.be.ok()
```

## true()

Asserts that the target is true.

```lua
expect(true).to.be.True()
```

# Configuration

Even if the `expect` module can be used as-is, it may also be configured to fit your needs. This can be done
in a file required before your tests.

## Options

In order to configure an option, simply set the appropriate value to `expect.parameters`. You can configure
the following options:

* `throw` is a function used to indicate a failing test. It defaults to `error` and must support the same syntax.

## Plugins

You should refer to the plugin documentation to see how to use it with `expect`. This is usually done by
requiring the plugin with the `expect` object as parameter:

```lua
local expect = require('expect')
require('expect-wonderful-plugin')(expect)
```
## Busted

As a configuration example, if you are using `busted`, you may write a `.busted` file containing:

```lua
local expect = require('expect')
local busted = require('busted')
require('expect-wonderful-plugin')(expect) -- This will require the plugin
expect.parameters.throw = busted.fail -- This will make failures appear as failures, not errors

return {} -- Return you busted configuration
```
