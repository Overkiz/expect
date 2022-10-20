# Expect - BDD expect notation for LUA tests

Widely inspired by `chaijs`, `expect` aims to bring the behavior-driven development “expect” notation to LUA tests.

```lua
expect(2 + 2).to.be.a('number').And.to.equal(4).but.Not.to.be.Nil()
```

# Installation

You can install `expect` using LuaRocks with the command:

```shell
luarocks install expect
```

# Usage

In order to use `expect` in your tests, look at the [usage manual](doc/usage.md).

If you want to write a new plugin, look at the [plugin manual](doc/plugin.md).

# Credits

Some parts of this projects are inspired/copied from:

- The NodeJS `chaijs` project: https://github.com/chaijs/chai
- The LUA `luassert` project: https://github.com/lunarmodules/luassert
