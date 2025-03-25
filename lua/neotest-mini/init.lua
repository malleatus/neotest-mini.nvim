--TODO: best way to type annotate neotest.Adapter

local lib = require("neotest.lib")

---@class NeotestAdapterMiniTest
---@see neotest.Adapter
local NeotestAdapterMini = {
	name = "neotest-mini",
}

---Directories to check for tests
local test_dirs = { "test", "tests", "spec" }

-- Expected file structure something like
-- lua/
--  my-module/
--    init.lua
--    foo.lua
-- tests/
--  my-module/
--    foo_spec.lua
NeotestAdapterMini.root = lib.files.match_root_pattern("lua")

---Filter directories when searching for test files
---@async
---@param name string Name of directory
---@param rel_path string Path to directory, relative to root
---@param root string Root directory of project
---@return boolean
function NeotestAdapterMini.filter_dir(name, rel_path, root)
	-- Skip hidden directories
	if name:sub(1, 1) == "." then
		return false
	end

	-- Check if current directory name is a test directory
	for _, dir in ipairs(test_dirs) do
		if name == dir then
			return true
		end
	end

	-- Check if any component of the relative path is a test directory
	for segment in string.gmatch(rel_path, "([^/]+)") do
		for _, dir in ipairs(test_dirs) do
			if segment == dir then
				return true
			end
		end
	end

	-- By default, exclude directories to optimize search
	return false
end

---@async
---@param file_path string
---@return boolean
function NeotestAdapterMini.is_test_file(file_path)
  local file_name = vim.fn.fnamemodify(file_path, ":t")
  return (file_name:match("_spec.lua") or file_name:match("^test_")) ~= nil
end

---Given a file path, parse all the tests within it.
---
---@see https://github.com/nvim-neotest/neotest/blob/dddbe8fe358b05b2b7e54fe4faab50563171a76d/lua/neotest/lib/treesitter/init.lua#L16-L39
---
---@async
---@param file_path string Absolute file path
---@return neotest.Tree | nil
function NeotestAdapterMini.discover_positions(file_path)
  --TODO: match describe/it
  --TODO: match T[] = MiniTest.new_set()
  --TODO: match T[..][...]... = function

  local query = [[
    ; see <https://github.com/echasnovski/mini.nvim/blob/main/TESTING.md>
    ; match: local T = MiniTest.new_set({})
    (variable_declaration
      (assignment_statement
        (variable_list
          name: (identifier) @minitest.identifier)
        (expression_list
          (function_call
            name: (_) @fn.name (#eq? @fn.name "MiniTest.new_set" ))))
    ) @import.minitest


    ; match x = function() ... end
    ; will have to filter in build_position to ensure assignment is to the minitest identifier
    (assignment_statement
      (variable_list) @maybe_minitest.assignment
      (expression_list
        value: (function_definition) @maybe_test.fn)
    ) @maybe_test.definition
  ]]
  ---@diagnostic disable-next-line: missing-fields
  return lib.treesitter.parse_positions(file_path, query, {
    nested_tests = false,
    require_namespaces = false,
    ---@diagnostic disable-next-line: assign-type-mismatch
    build_position = "require('neotest-mini')._build_position"
  })
end

---@param file_path string
---@param source string
---@param captured_nodes table<string, userdata>
---@return neotest.Position|neotest.Position[]|nil
function NeotestAdapterMini._build_position(file_path, source, captured_nodes)

  -- get the minitest definition(s)
  -- for each captured node
end

-- default impl
--
-- local function get_match_type(captured_nodes)
--   if captured_nodes["test.name"] then
--     return "test"
--   end
--   if captured_nodes["namespace.name"] then
--     return "namespace"
--   end
-- end
--
-- local function build_position(file_path, source, captured_nodes)
--   local match_type = get_match_type(captured_nodes)
--   if match_type then
--     ---@type string
--     local name = vim.treesitter.get_node_text(captured_nodes[match_type .. ".name"], source)
--     local definition = captured_nodes[match_type .. ".definition"]
--
--     return {
--       type = match_type,
--       path = file_path,
--       name = name,
--       range = { definition:range() },
--     }
--   end
-- end

---@param args neotest.RunArgs
---@return nil | neotest.RunSpec | neotest.RunSpec[]
function NeotestAdapterMini.build_spec(args) end

---@async
---@param spec neotest.RunSpec
---@param result neotest.StrategyResult
---@param tree neotest.Tree
---@return table<string, neotest.Result>
function NeotestAdapterMini.results(spec, result, tree) end


return NeotestAdapterMini
