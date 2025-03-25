#!/usr/bin/env -S nvim -l

-- setting this env will override all XDG paths
vim.env.LAZY_STDPATH = ".tests"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

-- Setup lazy.nvim
require("lazy.minit").setup({
	spec = {
		{
			dir = vim.uv.cwd(),
			opts = nil,
      -- see <https://github.com/nvim-neotest/neotest?tab=readme-ov-file#installation>
			dependencies = {
				"nvim-neotest/nvim-nio",
				"nvim-lua/plenary.nvim",
				"antoinemadec/FixCursorHold.nvim",
				"nvim-treesitter/nvim-treesitter",
				"nvim-neotest/neotest",
			},
		},
	},
})
