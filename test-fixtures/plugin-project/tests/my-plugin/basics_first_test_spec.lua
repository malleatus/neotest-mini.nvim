-- see <https://github.com/echasnovski/mini.nvim/blob/main/TESTING.md#first-test>

local T = MiniTest.new_set()

T['works'] = function()
  local x = 1 + 1
  if x ~= 2 then
    error('`x` is not equal to 2')
  end
end

return T


