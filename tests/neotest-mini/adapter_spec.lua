local expect = MiniTest.expect
local nio = require("nio")

-- TODO: set up a child nvim
-- see <https://github.com/echasnovski/mini.nvim/blob/main/TESTING.md#using-child-process>
-- see ~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/minit.lua
-- probably need to have a test_init.lua that loads stuff as expected.  seems
-- like it's going to overlap with minit a lot

local adapter = require("neotest-mini")
local root = vim.fn.getcwd()
local fixture_project = "test-fixtures/plugin-project"
local fixture_project_abs = vim.fs.joinpath(root, fixture_project)

local T = MiniTest.new_set({
	hooks = {
		-- pre_once = function ()
		-- end,
		-- pre_case = function ()
		-- end,
		post_case = function()
			vim.fn.chdir(root)
		end,
		-- post_once = function ()
		-- end,
	},
})

T["NeotestAdapterMiniTest"] = MiniTest.new_set()
T["NeotestAdapterMiniTest"][".root"] = MiniTest.new_set({
	parametrize = {
		{ "lua/my-plugin/init.lua" },
		{ "lua/my-plugin/" },
		{ "tests/my-plugin/plugin_spec.lua" },
	},
})
T["NeotestAdapterMiniTest"][".root"]["resolves"] = function(rel_path)
	expect.equality(adapter.root(vim.fs.joinpath(fixture_project, rel_path)), fixture_project_abs)
	expect.equality(adapter.root(vim.fs.joinpath(fixture_project_abs, rel_path)), fixture_project_abs)
end

T["NeotestAdapterMiniTest"][".filter_dir"] = MiniTest.new_set()

-- Test cases for directories that should be filtered out
T["NeotestAdapterMiniTest"][".filter_dir"]["skips hidden directories"] = function()
	expect.equality(adapter.filter_dir(".git", "", fixture_project_abs), false)
	expect.equality(adapter.filter_dir(".vscode", "", fixture_project_abs), false)
end

-- Test cases for test directories that should be included
T["NeotestAdapterMiniTest"][".filter_dir"]["includes test directories"] = function()
	expect.equality(adapter.filter_dir("test", "", fixture_project_abs), true)
	expect.equality(adapter.filter_dir("tests", "", fixture_project_abs), true)
	expect.equality(adapter.filter_dir("spec", "", fixture_project_abs), true)
end

-- Test cases for nested test directories
T["NeotestAdapterMiniTest"][".filter_dir"]["includes paths with test directories"] = function()
	expect.equality(adapter.filter_dir("my-module", "tests/my-plugin", fixture_project_abs), true)
	expect.equality(adapter.filter_dir("foo", "package/foo/tests", fixture_project_abs), true)
	expect.equality(adapter.filter_dir("bar", "package/foo/tests/bar", fixture_project_abs), true)
end

-- Test cases for regular directories that should be excluded
T["NeotestAdapterMiniTest"][".filter_dir"]["excludes regular directories"] = function()
	expect.equality(adapter.filter_dir("lua", "lua", fixture_project_abs), false)
	expect.equality(adapter.filter_dir("my-plugin", "lua/my-plugin", fixture_project_abs), false)
	expect.equality(adapter.filter_dir("package", "package", fixture_project_abs), false)
end

T["NeotestAdapterMiniTest"][".is_test_file"] = MiniTest.new_set()

-- Test cases for files that should be recognized as test files
T["NeotestAdapterMiniTest"][".is_test_file"]["identifies _spec.lua files"] = function()
	expect.equality(adapter.is_test_file("foo_spec.lua"), true)
	expect.equality(adapter.is_test_file("path/to/bar_spec.lua"), true)
	expect.equality(adapter.is_test_file("/absolute/path/to/baz_spec.lua"), true)
end

T["NeotestAdapterMiniTest"][".is_test_file"]["identifies files starting with test_"] = function()
	expect.equality(adapter.is_test_file("test_foo.lua"), true)
	expect.equality(adapter.is_test_file("path/to/test_bar.lua"), true)
	expect.equality(adapter.is_test_file("/absolute/path/to/test_baz.lua"), true)
end

-- Test cases for files that should not be recognized as test files
T["NeotestAdapterMiniTest"][".is_test_file"]["rejects regular lua files"] = function()
	expect.equality(adapter.is_test_file("regular.lua"), false)
	expect.equality(adapter.is_test_file("path/to/module.lua"), false)
	expect.equality(adapter.is_test_file("/absolute/path/to/init.lua"), false)
end

T["NeotestAdapterMiniTest"][".is_test_file"]["rejects files with 'test' or 'spec' in other patterns"] = function()
	expect.equality(adapter.is_test_file("testfile.lua"), false)
	expect.equality(adapter.is_test_file("my_test.lua"), false)
	expect.equality(adapter.is_test_file("spec_helper.lua"), false)
	expect.equality(adapter.is_test_file("special.lua"), false)
end

T["NeotestAdapterMiniTest"][".discover_positions"] = MiniTest.new_set({
	parametrize = {
		{
			"tests/my-plugin/basics_first_test_spec.lua",
			{
				file_path = "tests/my-plugin/basics_first_test_spec.lua",
				source = "hmmm",
				captured_nodes = {},
			},
		},
	},
})

T["NeotestAdapterMiniTest"][".discover_positions"]["calls _build_position with expected arguments"] = function(
	fixture_file_rel,
	expected_args
)
	local task = nio.run(function()
		local fixture_file = vim.fs.joinpath(fixture_project_abs, fixture_file_rel)

		-- Replace _build_position with a spy
		local original_build_position = adapter._build_position
		local build_position_calls = {}

		adapter._build_position = function(file_path, source, captured_nodes)
			table.insert(build_position_calls, {
				file_path = file_path,
				source = source,
				captured_nodes_keys = vim.tbl_keys(captured_nodes or {}),
			})

			return nil
		end

		-- Call discover_positions
		adapter.discover_positions(fixture_file)

		-- Restore the original function
		adapter._build_position = original_build_position

		-- Assert that _build_position was called
		expect.equality(#build_position_calls, 1)
		expect.equality(build_position_calls[0]["file_path"], "ok")
		expect.equality(build_position_calls[0]["source"], "ok")
		expect.equality(build_position_calls[0]["captured_node_keys"], { "ok" })
	end)
  task.wait()
  -- expect.equality(false, true)
end

return T
