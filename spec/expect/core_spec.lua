local expect = require('expect')

local function case(name, testedFunction, failure, plain)
  it('should ' .. (failure and 'fail ' or 'pass ') .. name, function()
    if failure then
      expect(testedFunction).to.failWith(failure, plain)
    else
      expect(testedFunction).to.Not.fail()
    end
  end)
end

describe('expect', function()
  for _, chainableWord in pairs({'a', 'also', 'and', 'at', 'be', 'been', 'but', 'does', 'has', 'have', 'is', 'that',
                                 'to', 'with', 'which'}) do
    describe(chainableWord, function()
      case('without changing the behavior of the test', function()
        expect(1 + 1)[chainableWord].equal(2)
      end)
    end)
  end

  describe('a', function()
    describe('(positive)', function()
      case('if target has the expected type', function()
        expect('foo').to.be.a('string')
      end)

      case('if target has another type', function()
        expect(12).to.be.a('string')
      end, 'expected %(number%) 12 to be a string$')
    end)

    describe('(negative)', function()
      case('if target has the expected type', function()
        expect(12).to.Not.be.a('number')
      end, 'expected %(number%) 12 not to be a number$')

      case('if target has another type', function()
        expect('foo').to.Not.be.a('number')
      end)
    end)
  end)

  describe('include', function()
    describe('(positive)', function()
      case('if string contains expected', function()
        expect('hello').to.include('ll')
      end)

      case('if string does not contains expected', function()
        expect('hello').to.include('hi')
      end, 'expected %(string%) \'hello\' to include %(string%) \'hi\'$')

      case('if array contains expected', function()
        expect({'one', 'two'}).to.include('one')
      end)

      case('if array does not contains expected', function()
        expect({'one', 'two'}).to.include('three')
      end, 'expected %(table.* to include %(string%) \'three\'$')

      case('if array contains expected table', function()
        expect({{
          a = 'one'
        }, {
          a = 'two'
        }}).to.include({
          a = 'one'
        })
      end, 'expected %(table.* to include %(table')

      case('if array deeply contains expected table', function()
        expect({{
          a = 'one'
        }, {
          a = 'two'
        }}).to.deep.include({
          a = 'one'
        })
      end)

      case('if table contains expected', function()
        expect({
          a = 'one',
          b = 'two'
        }).to.include('one')
      end)

      case('if table does not contains expected', function()
        expect({
          a = 'one',
          b = 'two'
        }).to.include('three')
      end, 'expected %(table.* to include %(string%) \'three\'$')

      case('if table contains expected table items', function()
        expect({
          a = 'one',
          b = 'two',
          c = 'three'
        }).to.include({
          a = 'one',
          c = 'three'
        })
      end)

      case('if table does not contains expected table items', function()
        expect({
          a = {'one'},
          b = 'two',
          c = 'three'
        }).to.include({
          a = {'one'}
        })
      end, 'expected %(table.* to include %(table')

      case('if table deep contains expected table items', function()
        expect({
          a = {'one'},
          b = 'two',
          c = 'three'
        }).to.deep.include({
          a = {'one'}
        })
      end)
    end)

    describe('(negative)', function()
      case('if string contains expected', function()
        expect('hello').to.Not.include('ll')
      end, 'expected %(string%) \'hello\' to not include %(string%) \'ll\'$')

      case('if string does not contains expected', function()
        expect('hello').to.Not.include('hi')
      end)

      case('if array does not contains expected', function()
        expect({'one', 'two'}).to.Not.include('three')
      end)

      case('if array deeply contains expected table', function()
        expect({{
          a = 'one'
        }, {
          a = 'two'
        }}).to.Not.deep.include({
          a = 'one'
        })
      end, 'expected %(table.* to not deeply include %(table')

      case('if table contains expected table items', function()
        expect({
          a = 'one',
          b = 'two',
          c = 'three'
        }).to.Not.include({
          a = 'one',
          c = 'three'
        })
      end, 'expected %(table.* to not include %(table')
    end)
  end)

  describe('ok', function()
    case('if target is truthy', function()
      expect('foo').to.be.ok()
    end)

    case('if target is falsy', function()
      expect(nil).to.be.ok()
    end, 'expected (nil) to be truthy', true)

    case('if target is truthy with negative test', function()
      expect('foo').to.Not.be.ok()
    end, 'expected (string) \'foo\' to be falsy', true)
  end)

  describe('true', function()
    case('if target is true', function()
      expect(true).to.be.True()
    end)

    case('if target is false', function()
      expect(nil).to.be.True()
    end, 'expected (nil) to be true', true)

    case('if target is true with negative test', function()
      expect(true).to.Not.be.True()
    end, 'expected (boolean) true to be false', true)
  end)

  describe('false', function()
    case('if target is false', function()
      expect(false).to.be.False()
    end)

    case('if target is true', function()
      expect(true).to.be.False()
    end, 'expected (boolean) true to be false', true)

    case('if target is false with negative test', function()
      expect(false).to.Not.be.False()
    end, 'expected (boolean) false to be true', true)
  end)

  describe('nil', function()
    case('if target is nil', function()
      expect(nil).to.be.Nil()
    end)

    case('if target is not nil', function()
      expect('foo').to.be.Nil()
    end, 'expected (string) \'foo\' to be nil', true)

    case('if target is nil with negative test', function()
      expect(nil).to.Not.be.Nil()
    end, 'expected (nil) not to be nil', true)
  end)

  describe('empty', function()
    describe('(positive)', function()
      case('if target is empty string', function()
        expect('').to.be.empty()
      end)

      case('if target is empty object', function()
        expect({}).to.be.empty()
      end)

      case('if target is non empty string', function()
        expect('foo').to.be.empty()
      end, 'expected (string) \'foo\' to be empty', true)

      case('if target is non empty object', function()
        expect({1}).to.be.empty()
      end, 'expected %(table.* to be empty$')

      case('if target is non treated object', function()
        expect(function()
        end).to.be.empty()
      end, 'expected function.* to be a string or a table$')
    end)

    describe('(negative)', function()
      case('if target is empty string', function()
        expect('').Not.to.be.empty()
      end, 'expected (string) \'\' not to be empty', true)

      case('if target is non empty object', function()
        expect({1}).Not.to.be.empty()
      end)
    end)
  end)

  describe('equal', function()
    describe('(positive)', function()
      case('if objects are strictly the same', function()
        expect('foo').to.equal('foo')
      end)

      case('if objects are not the same', function()
        expect({}).to.equal({})
      end, 'expected %(table: .*%) { } to equal %(table: .*%) { }$')
    end)

    describe('(negative)', function()
      case('if objects are strictly the same', function()
        expect('foo').to.Not.equal('foo')
      end, 'expected %(string%) \'foo\' to not equal %(string%) \'foo\'$')

      case('if objects are not the same', function()
        expect(12).to.Not.equal('foo')
      end)
    end)

    describe('(deep)', function()
      case('if objects are deeply equal', function()
        expect({
          a = 1
        }).to.deep.equal({
          a = 1
        })
      end)

      case('with negative test if objects are deeply equal', function()
        expect({
          a = 1
        }).to.Not.deep.equal({
          a = 1
        })
      end, 'expected %(table: .*%[a%] = 1.*to not deeply equal %(table: .*%[a%] = 1')

      case('if objects are not deeply equal', function()
        expect({
          'This should fail',
          failure = {
            deep = {
              again = 'yes',
              deeper = {
                diff = 'none'
              }
            },
            here = {
              again = 'yes',
              deeper = {
                diff = 'here'
              }
            }
          }
        }).to.deep.equal({
          'This should fail',
          failure = {
            deep = {
              again = 'yes',
              deeper = {
                diff = 'none'
              }
            },
            here = {
              again = 'yes',
              deeper = {
                diff = 'there'
              }
            }
          }
        })
      end, 'expected %(table.*more.*%*.*%[diff%].*here.* to deeply equal %(table: .*%) .*more.*there')
    end)
  end)

  describe('above', function()
    describe('(positive)', function()
      case('if target is above value', function()
        expect(2).to.be.above(1)
      end)

      case('if target is equal to value', function()
        expect(2).to.be.above(2)
      end, 'expected (number) 2 to be above 2', true)

      case('if target is below value', function()
        expect(2).to.be.above(3)
      end, 'expected (number) 2 to be above 3', true)
    end)

    describe('(negative)', function()
      case('if target is above value', function()
        expect(2).to.Not.be.above(1)
      end, 'expected (number) 2 to be at most 1', true)

      case('if target is equal to value', function()
        expect(2).to.Not.be.above(2)
      end)
    end)

    describe('(length)', function()
      case('if target length is above value', function()
        expect('foo').to.have.a.length.above(2)
      end)

      case('if target length is equal to value', function()
        expect({1, 2, 3}).to.have.a.length.above(3)
      end, 'expected %(table.* to have a length above 3 but got 3$')

      case('if target length is above value with negative test', function()
        expect('foo').to.Not.have.a.length.above(2)
      end, 'expected (string) \'foo\' to not have a length above 2', true)
    end)
  end)

  describe('least', function()
    describe('(positive)', function()
      case('if target is above value', function()
        expect(2).to.be.at.least(1)
      end)

      case('if target is equal to value', function()
        expect(2).to.be.at.least(2)
      end)

      case('if target is below value', function()
        expect(2).to.be.at.least(3)
      end, 'expected (number) 2 to be at least 3', true)
    end)

    describe('(negative)', function()
      case('if target is above value', function()
        expect(2).to.Not.be.at.least(1)
      end, 'expected (number) 2 to be below 1', true)

      case('if target is below value', function()
        expect(1).to.Not.be.at.least(2)
      end)
    end)

    describe('(length)', function()
      case('if target length is above value', function()
        expect('foo').to.have.a.lengthOf.at.least(2)
      end)

      case('if target length is below value', function()
        expect({1, 2, 3}).to.have.a.lengthOf.at.least(4)
      end, 'expected %(table.* to have a length of at least 4 but got 3$')

      case('if target length is above value with negative test', function()
        expect('foo').to.Not.have.a.lengthOf.at.least(2)
      end, 'expected (string) \'foo\' to have a length below 2', true)
    end)
  end)

  describe('below', function()
    describe('(positive)', function()
      case('if target is above value', function()
        expect(2).to.be.below(1)
      end, 'expected (number) 2 to be below 1', true)

      case('if target is equal to value', function()
        expect(2).to.be.below(2)
      end, 'expected (number) 2 to be below 2', true)

      case('if target is below value', function()
        expect(2).to.be.below(3)
      end)
    end)

    describe('(negative)', function()
      case('if target is below value', function()
        expect(2).to.Not.be.below(3)
      end, 'expected (number) 2 to be at least 3', true)

      case('if target is equal to value', function()
        expect(2).to.Not.be.below(2)
      end)
    end)

    describe('(length)', function()
      case('if target length is below value', function()
        expect('foo').to.have.a.length.below(4)
      end)

      case('if target length is equal to value', function()
        expect({1, 2, 3}).to.have.a.length.below(3)
      end, 'expected %(table.* to have a length below 3 but got 3$')

      case('if target length is below value with negative test', function()
        expect('foo').to.Not.have.a.length.below(4)
      end, 'expected (string) \'foo\' to not have a length below 4', true)
    end)
  end)

  describe('most', function()
    describe('(positive)', function()
      case('if target is above value', function()
        expect(2).to.be.at.most(1)
      end, 'expected (number) 2 to be at most 1', true)

      case('if target is equal to value', function()
        expect(2).to.be.at.most(2)
      end)

      case('if target is below value', function()
        expect(2).to.be.at.most(3)
      end)
    end)

    describe('(negative)', function()
      case('if target is below value', function()
        expect(2).to.Not.be.at.most(3)
      end, 'expected (number) 2 to be above 3', true)

      case('if target is above value', function()
        expect(2).to.Not.be.at.most(1)
      end)
    end)

    describe('(length)', function()
      case('if target length is below value', function()
        expect('foo').to.have.a.lengthOf.at.most(4)
      end)

      case('if target length is above value', function()
        expect({1, 2, 3}).to.have.a.lengthOf.at.most(2)
      end, 'expected %(table.* to have a length of at most 2 but got 3$')

      case('if target length is below value with negative test', function()
        expect('foo').to.Not.have.a.lengthOf.at.most(4)
      end, 'expected (string) \'foo\' to have a length above 4', true)
    end)
  end)

  describe('within', function()
    describe('(positive)', function()
      case('if target is within values', function()
        expect(2).to.be.within(1, 3)
      end)

      case('if target is equal to low value', function()
        expect(1).to.be.within(1, 3)
      end)

      case('if target is equal to high value', function()
        expect(3).to.be.within(1, 3)
      end)

      case('if target is outside values', function()
        expect(9).to.be.within(1, 3)
      end, 'expected (number) 9 to be within 1..3', true)
    end)

    describe('(negative)', function()
      case('if target is within values', function()
        expect(2).to.Not.be.within(1, 3)
      end, 'expected (number) 2 to not be within 1..3', true)

      case('if target is outside values', function()
        expect(9).to.Not.be.within(1, 3)
      end)
    end)

    describe('(length)', function()
      case('if target length is within values', function()
        expect('foo').to.have.a.length.within(2, 4)
      end)

      case('if target length is outside values', function()
        expect({1, 2, 3, 4}).to.have.a.length.within(1, 3)
      end, 'expected %(table.* to have a length within 1..3$')

      case('if target length is within values with negative test', function()
        expect('foo').to.Not.have.a.length.within(2, 4)
      end, 'expected (string) \'foo\' to not have a length within 2..4', true)
    end)
  end)

  describe('property', function()
    describe('(positive)', function()
      case('if target has property', function()
        expect({
          a = 1
        }).to.have.property('a')
      end)

      case('if target has property with matching value', function()
        expect({
          a = 1
        }).to.have.property('a', 1)
      end)

      case('if target has property with matching value tested after', function()
        expect({
          a = 1
        }).to.have.property('a').that.equals(1)
      end)

      case('if target does not have property', function()
        expect({
          a = 1
        }).to.have.property('b')
      end, 'expected %(table.* to have property b')

      case('if target has property with non matching value', function()
        expect({
          a = 1
        }).to.have.property('a', 2)
      end, 'expected %(table.* to have property a of %(number%) 2 but got %(number%) 1')

      case('if target has property with non matching value tested after', function()
        expect({
          a = 1
        }).to.have.property('a').that.equals(2)
      end, 'expected (number) 1 to equal (number) 2', true)

      case('if target has property with same value', function()
        expect({
          a = {
            x = 1
          }
        }).to.have.property('a', {
          x = 1
        })
      end, 'expected %(table.* to have property a of %(table.* but got %(table')

      case('if target has property with same value and deep comparison', function()
        expect({
          a = {
            x = 1
          }
        }).to.have.deep.property('a', {
          x = 1
        })
      end)
    end)

    describe('(negative)', function()
      case('if target has property', function()
        expect({
          a = 1
        }).to.Not.have.property('a')
      end, 'expected %(table.* to not have property a')

      case('if target has property with matching value', function()
        expect({
          a = 1
        }).to.Not.have.property('a', 1)
      end, 'expected %(table.* to not have property a of %(number%) 1')

      case('if target does not have property', function()
        expect({
          a = 1
        }).to.Not.have.property('b')
      end)

      case('if target has property with non matching value', function()
        expect({
          a = 1
        }).to.Not.have.property('a', 2)
      end)

      case('if target has property with same value', function()
        expect({
          a = {
            x = 1
          }
        }).to.Not.have.deep.property('a', {
          x = 1
        })
      end, 'expected %(table.* to not have deep property a of %(table')
    end)
  end)

  describe('lengthOf', function()
    describe('(positive)', function()
      case('if target string has expected length', function()
        expect('foo').to.have.lengthOf(3)
      end)

      case('if target array has expected size', function()
        expect({1, 2}).to.have.lengthOf(2)
      end)

      case('if target object has expected size', function()
        expect({
          a = 1,
          b = 2,
          c = 3,
          d = 4
        }).to.have.lengthOf(4)
      end)

      case('if target string does not have expected length', function()
        expect('foo').to.have.lengthOf(2)
      end, 'expected (string) \'foo\' to have a length of 2 but got 3', true)

      case('if target array does not have expected size', function()
        expect({1, 2}).to.have.lengthOf(3)
      end, 'expected %(table.* to have a length of 3 but got 2$')

      case('if target object has expected size', function()
        expect({
          a = 1,
          b = 2,
          c = 3,
          d = 4
        }).to.have.lengthOf(3)
      end, 'expected %(table.* to have a length of 3 but got 4$')
    end)

    describe('(negative)', function()
      case('if target string has expected length', function()
        expect('foo').to.Not.have.lengthOf(3)
      end, 'expected (string) \'foo\' to not have a length of 3', true)

      case('if target array does not have expected size', function()
        expect({1, 2}).to.Not.have.lengthOf(3)
      end)
    end)
  end)

  describe('match', function()
    case('if target matches pattern', function()
      expect('foo').to.match('f.o$')
    end)

    case('if target does not match pattern', function()
      expect('foo').to.match('bar')
    end, 'expected (string) \'foo\' to match bar', true)

    case('if target matches pattern with negative test', function()
      expect('foo').to.Not.match('f.o$')
    end, 'expected (string) \'foo\' to not match f.o$', true)
  end)

  describe('keys', function()
    describe('(positive)', function()
      case('if target table has all keys', function()
        expect({
          a = 1,
          b = 2
        }).to.have.all.keys('a', 'b')
      end)

      case('if target array has all keys', function()
        expect({'a', 'b'}).to.have.keys(1, 2)
      end)

      case('if target has any key', function()
        expect({
          a = 1,
          b = 2
        }).to.have.any.keys('c', 'b')
      end)

      case('if target contain all keys', function()
        expect({
          a = 1,
          b = 2,
          c = 3
        }).to.include.all.keys('a', 'b')
      end)

      case('if target has more keys', function()
        expect({'a', 'b'}).to.have.all.keys(1)
      end, 'expected %(table.* to have key 1$')

      case('if target does not have all keys', function()
        expect({'a', 'b'}).to.have.all.keys(1, 2, 3)
      end, 'expected %(table.* to have keys 1, 2 and 3$')

      case('if target does not have any key', function()
        expect({'a', 'b'}).to.have.any.keys(3, 4)
      end, 'expected %(table.* to have keys 3 or 4$')

      case('if target does not contain all keys', function()
        expect({
          a = 1,
          b = 2,
          c = 3
        }).to.include.all.keys('a', 'b', 'c', 'd')
      end, 'expected %(table.* to contain keys a, b, c and d$')

      case('if target table has all table keys', function()
        expect({
          [{
            a = 1
          }] = true,
          [{
            b = 2
          }] = true
        }).to.have.all.keys({
          a = 1
        }, {
          b = 2
        })
      end, 'expected %(table.* to have keys')

      case('if target table has all table deep keys', function()
        expect({
          [{
            a = 1
          }] = true,
          [{
            b = 2
          }] = true
        }).to.have.all.deep.keys({
          a = 1
        }, {
          b = 2
        })
      end)
    end)

    describe('(negative)', function()
      case('if target has all keys', function()
        expect({
          a = 1,
          b = 2
        }).to.Not.have.all.keys('a', 'b')
      end, 'expected %(table.* to not have keys a and b$')

      case('if target has any key', function()
        expect({
          a = 1,
          b = 2
        }).to.Not.have.any.keys('c', 'b')
      end, 'expected %(table.* to not have keys c or b$')

      case('if target contain all keys', function()
        expect({
          a = 1,
          b = 2,
          c = 3
        }).to.Not.include.all.keys('a', 'b')
      end, 'expected %(table.* to not contain keys a and b$')

      case('if target has more keys', function()
        expect({'a', 'b'}).to.Not.have.all.keys(1)
      end)

      case('if target does not have any key', function()
        expect({'a', 'b'}).to.Not.have.any.keys(3, 4)
      end)
    end)
  end)

  describe('fail', function()
    -- Override default, because this function cannot be tested by itself
    local function case(name, testedFunction, failure)
      it('should ' .. (failure and 'fail ' or 'pass ') .. name, function()
        local ok, res = pcall(testedFunction)
        if failure then
          expect(ok, 'expected to fail').to.be.False()
          expect(res).to.match(failure)
        else
          expect(ok, 'call result').to.be.True()
        end
      end)
    end

    local function failingFunction()
      error('Oh no! This function is failing!')
    end

    local function successfulFunction()
    end

    describe('(positive)', function()
      case('with failing function', function()
        expect(failingFunction).to.fail()
      end)

      case('with function throwing matching error', function()
        expect(failingFunction).to.failWith('is%sfailing')
      end)

      case('with function throwing exact error', function()
        expect(failingFunction).to.failWith('is failing', true)
      end)

      case('with function throwing expected number as string', function()
        expect(function()
          error('12')
        end).to.failWith(12)
      end)

      case('with function throwing expected number', function()
        expect(function()
          error(12)
        end).to.failWith(12)
      end)

      case('with function throwing expected table', function()
        expect(function()
          error({
            'item1',
            key = 'value1'
          })
        end).to.failWith({
          'item1',
          key = 'value1'
        })
      end)

      case('with successful function', function()
        expect(successfulFunction).to.fail()
      end, 'expected function.* to fail, but it was successful$')

      case('with successful function, even if an error was specified', function()
        expect(successfulFunction).to.failWith('any error')
      end, 'expected function.* to fail, but it was successful$')

      case('with function throwing non matching error', function()
        expect(failingFunction).to.failWith('is successful')
      end,
        'expected function.* to fail with error %(string%) \'is successful\', but %(string%) \'Oh no! This function is failing!\' was thrown$')

      case('with function throwing wrong error', function()
        expect(failingFunction).to.failWith('is%sfailing', true)
      end,
        'expected function.* to fail with error %(string%) \'is%%sfailing\', but %(string%) \'Oh no! This function is failing!\' was thrown$')

      case('with function throwing wrong number as string', function()
        expect(function()
          error('12')
        end).to.failWith(144)
      end, 'expected function.* to fail with error %(number%) 144, but %(string%) \'12\' was thrown$')

      case('with function throwing wrong number', function()
        expect(function()
          error(12)
        end).to.failWith(144)
      end, 'expected function.* to fail with error %(number%) 144, but') -- Cannot test more, lua 5.1 throws a string anyway

      case('with function throwing wrong table', function()
        expect(function()
          error({
            'This should fail',
            failure = true
          })
        end).to.failWith({
          'This should fail',
          failure = false
        })
      end, 'expected function.* to fail with error %(table: .*%) .*false.*, but %(table: .*%) .*true.* was thrown$')
    end)

    describe('(negative)', function()
      case('with successful function', function()
        expect(successfulFunction).to.Not.fail()
      end)

      case('with successful function, even if an error was specified', function()
        expect(successfulFunction).to.Not.failWith('any error')
      end)

      case('with function throwing non matching error', function()
        expect(failingFunction).to.Not.failWith('is successful')
      end)

      case('with failing function', function()
        expect(failingFunction).to.Not.fail()
      end, 'expected function.* not to fail, but %(string%) \'Oh no! This function is failing!\' was thrown$')

      case('with function throwing matching error', function()
        expect(failingFunction).to.Not.failWith('is failing')
      end, 'expected function.* not to fail with error %(string%) \'is failing\'')
    end)
  end)

  describe('satisfy', function()
    local matcher = function(value)
      return value == 1
    end

    case('if target satisfies matcher', function()
      expect(1).to.satisfy(matcher)
    end)

    case('if target does not satisfy matcher', function()
      expect(2).to.satisfy(matcher)
    end, 'expect (number) 2 to satisfy function', true)

    case('if target satisfies matcher with negative test', function()
      expect(1).to.Not.satisfy(matcher)
    end, 'expect (number) 1 to not satisfy function', true)
  end)

  describe('closeTo', function()
    case('if target is equal to expected', function()
      expect(1.5).to.be.closeTo(1.5, 0.5)
    end)

    case('if target is above but close to expected', function()
      expect(1.5).to.be.closeTo(1, 0.5)
    end)

    case('if target is below but close to expected', function()
      expect(1.5).to.be.closeTo(2, 0.5)
    end)

    case('if target is too different from expected', function()
      expect(1.5).to.be.closeTo(3, 0.5)
    end, 'expected (number) 1.5 to be close to 3 +/- 0.5', true)

    case('if target is equal to expected with negative test', function()
      expect(1.5).Not.to.be.closeTo(1.2, 0.5)
    end, 'expected (number) 1.5 not to be close to 1.2 +/- 0.5', true)
  end)

  describe('members', function()
    describe('(positive)', function()
      case('if target has same unordered members', function()
        expect({1, 2, 3}).to.have.members(2, 1, 3)
      end)

      case('if target has same duplicated members', function()
        expect({1, 2, 2}).to.have.members(2, 1, 2)
      end)

      case('if target has same table members', function()
        expect({{
          a = 1
        }}).to.have.members({
          a = 1
        })
      end, 'expected %(table.* to have the same members as table.*')

      case('if target has same table members with deep comparison', function()
        expect({{
          a = 1
        }}).to.have.deep.members({
          a = 1
        })
      end)

      case('if target does not have same members', function()
        expect({1, 2, 3}).to.have.members(2, 4, 3)
      end, 'expected %(table.* to have the same members as 2, 4, 3$')

      case('if target has less members', function()
        expect({1, 2, 3}).to.have.members(2, 1, 3, 4)
      end, 'expected %(table.* to have the same members as 2, 1, 3, 4$')

      case('if target has more members', function()
        expect({1, 2, 3}).to.have.members(2, 1)
      end, 'expected %(table.* to have the same members as 2, 1$')

      case('if target has same unordered members with ordered comparison', function()
        expect({1, 2, 3}).to.have.ordered.members(2, 1, 3)
      end, 'expected %(table.* to have the same ordered members as 2, 1, 3')

      case('if target has same ordered members', function()
        expect({1, 2, 3}).to.have.ordered.members(1, 2, 3)
      end)

      case('if target has more members with include', function()
        expect({1, 2, 3}).to.include.members(2, 1)
      end)

      case('if target has more ordered members with include', function()
        expect({1, 2, 3}).to.include.ordered.members(2, 3)
      end)
    end)

    describe('(negative)', function()
      case('if target has same unordered members', function()
        expect({1, 2, 3}).to.Not.have.members(2, 1, 3)
      end, 'expected %(table.* to not have the same members as 2, 1, 3$')

      case('if target does not have same members', function()
        expect({1, 2, 3}).to.Not.have.members(2, 4, 3)
      end)

      case('if target has same unordered members with ordered comparison', function()
        expect({1, 2, 3}).to.Not.have.ordered.members(2, 1, 3)
      end)

      case('if target has same ordered members', function()
        expect({1, 2, 3}).to.Not.have.ordered.members(1, 2, 3)
      end, 'expected %(table.* to not have the same ordered members as 1, 2, 3$')

      case('if target has more members with include', function()
        expect({1, 2, 3}).to.Not.include.members(2, 1)
      end, 'expected %(table.* to not be an ordered superset of 2, 1$')
    end)
  end)
end)
