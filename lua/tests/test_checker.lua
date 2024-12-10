---@class test_options
local M = {}

---@class Checker
local checker = require("lua.textangle.checker")

local function test_is_valid_option_name()
   assert(not checker.is_valid_option_name(""))
   assert(not checker.is_valid_option_name("aksjfdf"))
   assert(checker.is_valid_option_name("line_width"))
   assert(checker.is_valid_option_name("hyphenate"))
   assert(checker.is_valid_option_name("hyphenate_minimum_gap"))
end

local function test_has_unknown_option()
   local input = {}
   local has_unknown = nil
   local unknown_name = nil

   has_unknown, unknown_name = checker.has_unknown_options()
   assert(not has_unknown)
   assert(unknown_name == "")

   input = {}
   has_unknown, unknown_name = checker.has_unknown_options(input)
   assert(not has_unknown)
   assert(unknown_name == "")

   input = { ["line_width"] = 1 }
   has_unknown, unknown_name = checker.has_unknown_options(input)
   assert(not has_unknown)
   assert(unknown_name == "")

   input = { ["line_width"] = 1, ["hyphenate"] = true }
   has_unknown, unknown_name = checker.has_unknown_options(input)
   assert(not has_unknown)
   assert(unknown_name == "")

   input = { ["wrong"] = 1 }
   has_unknown, unknown_name = checker.has_unknown_options(input)
   assert(has_unknown)
   assert(unknown_name == "wrong")

   input = { ["line_width"] = 1, ["wrong"] = 1 }
   has_unknown, unknown_name = checker.has_unknown_options(input)
   assert(has_unknown)
   assert(unknown_name == "wrong")

   input = { ["line_width"] = 1, ["hyphena"] = 1 }
   has_unknown, unknown_name = checker.has_unknown_options(input)
   assert(has_unknown)
   assert(unknown_name == "hyphena")
end

local function test_are_valid_types()
   local input = nil
   local valid = nil
   local msg = nil
   input = {}
   valid, msg = checker.are_valid_types(input)
   assert(valid == true)
   assert(msg == "")
   input = { ["line_width"] = 2 }
   valid, msg = checker.are_valid_types(input)
   assert(valid == true)
   assert(msg == "")
   input = { ["line_width"] = "s" }
   valid, msg = checker.are_valid_types(input)
   assert(valid == false)
   assert(string.find(msg, "line_width") ~= nil)
   input = { ["line_width"] = true }
   valid, msg = checker.are_valid_types(input)
   assert(valid == false)
   assert(string.find(msg, "line_width") ~= nil)
   input = { ["line_width"] = {} }
   valid, msg = checker.are_valid_types(input)
   assert(valid == false)
   assert(string.find(msg, "line_width") ~= nil)
   input = { ["line_width"] = function() end }
   valid, msg = checker.are_valid_types(input)
   assert(valid == false)
   assert(string.find(msg, "line_width") ~= nil)

   input = { ["line_width"] = 3, ["hyphenate"] = 1 }
   valid, msg = checker.are_valid_types(input)
   assert(valid == false)
   assert(string.find(msg, "line_width") == nil)
   assert(string.find(msg, "hyphenate") ~= nil)
   input = { ["hyphenate"] = 1, ["line_width"] = 3 }
   valid, msg = checker.are_valid_types(input)
   assert(valid == false)
   assert(string.find(msg, "line_width") == nil)
   assert(string.find(msg, "hyphenate") ~= nil)
end

function M.run()
   test_is_valid_option_name()
   test_has_unknown_option()
   test_are_valid_types()
end

return M
