-- see <https://github.com/echasnovski/mini.nvim/blob/main/TESTING.md#test-parametrization>

local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local T = new_set()

-- Each parameter should be an array to allow parametrizing multiple arguments
T['parametrize'] = new_set({ parametrize = { { 1 }, { 2 } } })

-- This will result into two cases. First will fail.
T['parametrize']['works'] = function(x)
  eq(x, 2)
end

-- Parametrization can be nested. Cases are "multiplied" with every combination
-- of parameters.
T['parametrize']['nested'] = new_set({ parametrize = { { '1' }, { '2' } } })

-- This will result into four cases. Two of them will fail.
T['parametrize']['nested']['works'] = function(x, y)
  eq(tostring(x), y)
end

-- Parametrizing multiple arguments
T['parametrize multiple arguments'] = new_set({ parametrize = { { 1, 1 }, { 2, 2 } } })

-- This will result into two cases. Both will pass.
T['parametrize multiple arguments']['works'] = function(x, y)
  eq(x, y)
end

return T
