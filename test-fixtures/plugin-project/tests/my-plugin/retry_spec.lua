-- see <https://github.com/echasnovski/mini.nvim/blob/f048957e4e2ce8a7f44cc906450f5579ca9cfa20/TESTING.md#retry>

local new_set = MiniTest.new_set

local T = new_set()

-- Each case will be attempted until first success at most 5 times
T['n_retry'] = new_set({ n_retry = 5 })

-- With default `n_retry = 1` this case will fail 1 out of 2 runs.
-- With `n_retry = 5` this case will fail 1 out of 32 runs.
T['n_retry']['case'] = function()
  math.randomseed(vim.loop.hrtime())
  assert(math.random() < 0.5)
end

return T
