-- see <https://github.com/echasnovski/mini.nvim/blob/main/TESTING.md#writing-custom-expectation>

local T = MiniTest.new_set()

local expect_match = MiniTest.new_expectation(
  -- Expectation subject
  'string matching',
  -- Predicate
  function(str, pattern) return str:find(pattern) ~= nil end,
  -- Fail context
  function(str, pattern)
    return string.format('Pattern: %s\nObserved string: %s', vim.inspect(pattern), str)
  end
)

T['string matching'] = function()
  local x = 'abcd'
  -- This will pass
  expect_match(x, '^a')

  -- This will fail
  expect_match(x, 'x')
end

return T
