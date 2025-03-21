-- see <https://github.com/echasnovski/mini.nvim/blob/main/TESTING.md#hooks>

local new_set = MiniTest.new_set
local expect, eq = MiniTest.expect, MiniTest.expect.equality

local T = new_set()

local n = 0
local increase_n = function() n = n + 1 end

T['hooks'] = new_set({
  hooks = { pre_once = increase_n, pre_case = increase_n, post_case = increase_n, post_once = increase_n },
})

T['hooks']['work'] = function()
  -- `n` will be increased twice: in `pre_once` and `pre_case`
  eq(n, 2)
end

T['hooks']['work again'] = function()
  -- `n` will be increased twice: in `post_case` from previous case and
  -- `pre_case` before this one
  eq(n, 4)
end

T['after hooks set'] = function()
  -- `n` will be again increased twice: in `post_case` from previous case and
  -- `post_once` after last case in T['hooks'] test set
  eq(n, 6)
end

return T
