-- see <https://github.com/echasnovski/mini.nvim/blob/main/TESTING.md#builtin-expectations>

local T = MiniTest.new_set()
local expect, eq = MiniTest.expect, MiniTest.expect.equality

local x = 1 + 1

-- This is so frequently used that having short alias proved useful
T['expect.equality'] = function()
  eq(x, 2)
end

T['expect.no_equality'] = function()
  expect.no_equality(x, 1)
end

T['expect.error'] = function()
  -- This expectation will pass because function will throw an error
  expect.error(function()
    if x == 2 then error('Deliberate error') end
  end)
end

T['expect.no_error'] = function()
  -- This expectation will pass because function will *not* throw an error
  expect.no_error(function()
    if x ~= 2 then error('This should not be thrown') end
  end)
end

return T
