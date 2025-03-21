-- see <https://github.com/echasnovski/mini.nvim/blob/main/TESTING.md#basics>

local T = MiniTest.new_set()

T['big scope'] = new_set()

T['big scope']['works'] = function()
  local x = 1 + 1
  MiniTest.expect.equality(x, 2)
end

T['big scope']['also works'] = function()
  local x = 2 + 2
  MiniTest.expect.equality(x, 4)
end

T['out of scope'] = function()
  local x = 3 + 3
  MiniTest.expect.equality(x, 6)
end

return T
