-- see <https://github.com/echasnovski/mini.nvim/blob/main/TESTING.md#basics>

describe('big scope', function()
  it('works', function()
    local x = 1 + 1
    MiniTest.expect.equality(x, 2)
  end)

  it('also works', function()
    local x = 2 + 2
    MiniTest.expect.equality(x, 4)
  end)
end)

it('out of scope', function()
  local x = 3 + 3
  MiniTest.expect.equality(x, 6)
end)

-- NOTE: when using this style, no test set should be returned
