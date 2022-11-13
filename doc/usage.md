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
expect({a = 1}).to.Not.have.property('b')
expect({1, 2}).to.be.a('table').that.does.Not.include(3)
```

## all

Causes some assertions that follow in the chain to require that the target matches the full expression. This
is the opposite of `any`.

```lua
expect({a = 1, b = 2}).to.have.all.keys('a', 'b')
```

## any

Causes some assertions that follow in the chain to only require that the target matches only a part of the
expression. This is the opposite of `all`.

```lua
expect({a = 1, b = 2}).to.Not.have.any.keys('c', 'd')
```

## deep

Causes some assertions that follow in the chain to use deep equality instead of strict equality.

```lua
expect({a = 1}).to.deep.equal({a = 1})
expect({a = 1}).to.Not.equal({a = 1})

expect({{a = 1}}).to.deep.include({a = 1})
expect({{a = 1}}).to.Not.include({a = 1})

expect({{a = 1} = true}).to.have.deep.key({a = 1})
expect({{a = 1} = true}).to.Not.have.key({a = 1})

expect({x = {a = 1}}).to.have.deep.property('x', {a = 1})
expect({x = {a = 1}}).to.Not.have.property('x', {a = 1})
```

## a(type)

Asserts that the target’s type is equal to the given string type. Types are case insensitive.

```lua
expect(12).to.be.a('number')
expect('foo').to.be.a('string')
```

The alias `.an` can be used interchangeably with `.a`.

## above(n)

Asserts that the target is a number greater than the given number `n`.

```lua
expect(2).to.be.above(1)
```

Add `lengthOf` earlier in the chain to assert that the target’s length is greater than the given number `n`.

```lua
expect("foo").to.have.a.length.above(2)
expect({1, 2, 3}).to.have.a.length.above(2)
```

The aliases `gt` and `greaterThan` can be used interchangeably with `above`.

## below(n)

Asserts that the target is a number less than the given number `n`.

```lua
expect(1).to.be.below(2)
```

Add `lengthOf` earlier in the chain to assert that the target’s length is less than the given number `n`.

```lua
expect("foo").to.have.a.length.below(4)
expect({1, 2, 3}).to.have.a.length.below(4)
```

The aliases `lt` and `lessThan` can be used interchangeably with `below`.

## empty()

When the target is a string, asserts that the target’s length is zero.

```lua
expect('').to.be.empty()
```

When the target is an object, asserts that the target does not have any property.

```lua
expect({}).to.be.empty()
```

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

## include(val)

When the target is a string, asserts that the string representation of `val` is a substring of the target.

```lua
expect('foobar').to.include('foo')
```

When the target is an object (including an array), asserts that the given `val` is a member of the target.

```lua
expect({1, 2, 3}).to.include(2)
expect({a = 1, b = 2}).to.include(2)
```

When both the target and the given `val` are objects, but not arrays, and the given `val` is not a member of
the target, asserts that the given `val`’s properties are a subset of the target’s properties.

```lua
expect({a = 1, b = 2, c = 3}).to.include({a = 1, b = 2})
```

Note that sparsed arrays are considered arrays unless the count of holes is greater than the count of
elements.

By default, strict equality is used to compare array members and object properties. Add `.deep` earlier in
the chain to use deep equality instead.

```lua
expect({{a = 1}}).to.deep.include({a = 1})
expect({{a = 1}}).to.Not.include({a = 1})
expect({x = {a = 1}}).to.deep.include({x = {a = 1}})
expect({x = {a = 1}}).to.Not.include({x = {a = 1}})
```

`include` can also be used as a language chain, causing some assertions that follow in the chain to require
the target to be a superset of the expected set.

```lua
expect({a = 1, b = 2, c = 3}).to.include.all.keys('a', 'b')
expect({a = 1, b = 2, c = 3}).to.Not.have.all.keys('a', 'b')
```

The aliases `includes`, `contain`, `contains` can be used interchangeably with `include`.

## keys(key1[, key2[, ...]])

Asserts that the target table has the given keys.

```lua
expect({a = 1, b = 2}).to.have.all.keys('a', 'b')
expect({'a', 'b'}).to.have.all.keys(1, 2)
```

By default, strict equality is used to compare keys. Add `deep` earlier in the chain to use deep equality
instead.

```lua
expect([{a = 1}] = true).to.have.all.deep.keys({a = 1})
expect([{a = 1}] = true).to.Not.have.all.keys({a = 1})
```

By default, the target must have all of the given keys and no more. Add `any` earlier in the chain to only
require that the target have at least one of the given keys.

Note that `all` is used by default when neither `all` nor `any` appear earlier in the chain.

Add `include` earlier in the chain to require that the target’s keys be a superset of the expected keys,
rather than identical sets.

```lua
expect({a = 1, b = 2, c = 3}).to.include.all.keys('a', 'b')
expect({a = 1, b = 2, c = 3}).to.Not.have.all.keys('a', 'b')
```

However, if `any` and `include` are combined, only the `any` takes effect. The `include` is ignored in this
case.

```lua
-- Both assertions are identical
expect({a = 1}).to.have.any.keys('a', 'b')
expect({a = 1}).to.include.any.keys('a', 'b')
```

The alias `key` can be used interchangeably with `keys`.

## least(n)

Asserts that the target is a number greater than or equal to the given number `n`.

```lua
expect(2).to.be.at.least(1)
```

Add `lengthOf` earlier in the chain to assert that the target’s length is greater than or equal to the given
number `n`.

```lua
expect("foo").to.have.a.lengthOf.at.least(2)
expect({1, 2, 3}).to.have.a.lengthOf.at.least(2)
```

The aliases `gte` and `greaterThanOrEqual` can be used interchangeably with `least`.

## lengthOf(n)

Asserts that the target’s length (or size) is equal to the given number `n`.

```lua
expect({1, 2, 3}).to.have.lengthOf(3)
expect('foo').to.have.lengthOf(3)
expect({a = 1, b = 2, c = 3}).to.have.lengthOf(3);
```

`lengthOf` can also be used as a language chain, causing some numeric features to use target’s length as the
target.

The alias `length` can be used interchangeably with `lengthOf`.

## match(pattern)

Asserts that the target matches the given pattern.

```lua
expect('foo').to.match('^f.o$')
```

## most(n)

Asserts that the target is a number less than or equal to the given number `n`.

```lua
expect(1).to.be.at.most(2)
```

Add `lengthOf` earlier in the chain to assert that the target’s length is less than or equal to the given
number `n`.

```lua
expect("foo").to.have.a.lengthOf.at.most(4)
expect({1, 2, 3}).to.have.a.lengthOf.at.most(4)
```

The aliases `lte` and `lessThanOrEqual` can be used interchangeably with `most`.

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

## property(name[, value])

Asserts that the target has a property with the given key `name`.

```lua
expect({a = 1}).to.have.property('a')
```

When `value` is provided, `property` also asserts that the property’s value is equal to the given `value`.

```lua
expect({a = 1}).to.have.property('a', 1)
```

By default, strict equality is used. Add `deep` earlier in the chain to use deep equality instead.

```lua
expect({x = {a = 1}}).to.have.deep.property('x', {a = 1})
expect({x = {a = 1}}).to.Not.have.property('x', {a = 1})
```

`property` changes the target of any assertions that follow in the chain to be the value of the property from
the original target object.

```lua
expect({a = 1}).to.have.property('a').that.is.a('number')
```

## true()

Asserts that the target is true.

```lua
expect(true).to.be.True()
```

## within(low, high)

Asserts that the target is a number greater than or equal to the given number `low` and less than or equal to
the given number `high`.

```lua
expect(2).to.be.within(1, 3)
expect(2).to.be.within(2, 3)
expect(2).to.be.within(1, 2)
```

Add `lengthOf` earlier in the chain to assert that the target’s length is greater than or equal to the given
number `low` and less than or equal to the given number `high`.

```lua
expect("foo").to.have.a.length.within(2, 4)
expect({1, 2, 3}).to.have.a.length.within(2, 4)
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
