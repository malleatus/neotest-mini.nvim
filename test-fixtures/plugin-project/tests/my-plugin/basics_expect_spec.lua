-- see <https://github.com/echasnovski/mini.nvim/blob/main/TESTING.md#basics>
local T = MiniTest.new_set()

T['works'] = function()
  local x = 1 + 1
  MiniTest.expect.equality(x, 2)
end

return T
