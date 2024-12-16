---@class test_text
local M = {}

---@class Text
local text = require("lua.textangle.text")

local function test_get_whitespace_prefix()
   local input = nil
   local output = nil

   input = " \t word efe f     fdhf edf"
   output = text.get_whitespace_prefix(input)
   assert(type(output) == "string")
   assert(output == " \t ")

   input = "\ta\t word efe f     fdhf edf"
   output = text.get_whitespace_prefix(input)
   assert(type(output) == "string")
   assert(output == "\t")

   input = "\t\t word efe f     fdhf edf"
   output = text.get_whitespace_prefix(input)
   assert(type(output) == "string")
   assert(output == "\t\t ")
   input = "     word efe f     fdhf edf"
   output = text.get_whitespace_prefix(input)
   assert(type(output) == "string")
   assert(output == "     ")
end

local function test_clear_whitespace_prefixes()
   local input = nil
   local output = nil

   input = { "     ", "    dwdw" }
   output = text.clear_whitespace_prefixes(input)
   assert(type(output) == "table")
   assert(#output == 2)
   assert(output[1] == "")
   assert(output[2] == "dwdw")

   input = { "  Some simple ", "       words" }
   output = text.clear_whitespace_prefixes(input)
   assert(type(output) == "table")
   assert(#output == 2)
   assert(output[1] == "Some simple ")
   assert(output[2] == "words")
end

local function test_get_prefix()
   local input_line = nil
   local prefixes = nil
   local output = nil

   input_line = ""
   prefixes = {}
   output = text.get_prefix(input_line, prefixes)
   assert(output == "")

   input_line = "The prefix  some words"
   prefixes = { " e-fef ", "d", "The prefix " }
   output = text.get_prefix(input_line, prefixes)
   assert(output == "The prefix ")
end

local function test_unravel_lines()
   local input = nil
   local output = nil

   input = { "Some words!", "", "", "and some more words" }
   output = text.unravel_lines(input)
   assert(type(output) == "string")
   assert(output == "Some words! and some more words", "Got " .. output)

   input = { "Some\twords!", "", "", "and some more words" }
   output = text.unravel_lines(input)
   assert(type(output) == "string")
   assert(output == "Some words! and some more words", "Got " .. output)
end

local function test_hyphenise()
   -- Empty input check.
   local input = ""
   local max_width = 2
   local output = text.hyphenise(input, max_width)
   assert(type(output) == "table")
   assert(#output == 1)
   assert(output[1] == "")
   input = "abcdefg"
   max_width = 9
   output = text.hyphenise(input, max_width)
   assert(type(output) == "table")
   assert(#output == 1)
   assert(output[1] == "abcdefg")
   max_width = 3
   output = text.hyphenise(input, max_width)
   assert(type(output) == "table")
   assert(#output == 3)
   assert(output[1] == "ab-", "Instead got " .. output[1])
   assert(output[2] == "cd-", "Instead got " .. output[2])
   assert(output[3] == "efg")
   input = "abcdefghijklmnop"
   max_width = 4
   output = text.hyphenise(input, max_width)
   assert(type(output) == "table")
   assert(#output == 5)
   assert(output[1] == "abc-")
   assert(output[2] == "def-")
   assert(output[3] == "ghi-")
   assert(output[4] == "jkl-")
   assert(output[5] == "mnop")

   -- Testing non-default first_width.
   max_width = 6
   local first_width = 2
   output = text.hyphenise(input, max_width, first_width)
   assert(type(output) == "table")
   assert(#output == 4)
   assert(output[1] == "a-", "Got " .. output[1])
   assert(output[2] == "bcdef-", "Got " .. output[2])
   assert(output[3] == "ghijk-")
   assert(output[4] == "lmnop")
   max_width = 3
   first_width = 5
   output = text.hyphenise(input, max_width, first_width)
   assert(type(output) == "table")
   assert(#output == 7)
   assert(output[1] == "abcd-", "Got " .. output[1])
   assert(output[2] == "ef-", "Got " .. output[2])
   assert(output[3] == "gh-")
   assert(output[4] == "ij-")
   assert(output[5] == "kl-")
   assert(output[6] == "mn-")
   assert(output[7] == "op")
end

local function test_format()
   local input = { "" }
   local line_width = 5
   local hyphenate = false
   local hyphenate_minimum_gap = 10
   local hyphenate_overflow = false
   local keep_indent = false
   local keep_prefixes = {}
   -- Empty input checks.
   local formatted_text = text.format(
      input,
      line_width,
      hyphenate,
      hyphenate_minimum_gap,
      hyphenate_overflow,
      keep_indent,
      keep_prefixes
   )
   assert(#formatted_text == 1, "Got length " .. #formatted_text)
   assert(type(formatted_text[1]) == "string")
   assert(formatted_text[1] == "")
   input = { "", "   ", "" }
   formatted_text = text.format(
      input,
      line_width,
      hyphenate,
      hyphenate_minimum_gap,
      hyphenate_overflow,
      keep_indent,
      keep_prefixes
   )
   assert(#formatted_text == 1)
   assert(type(formatted_text[1]) == "string")
   assert(formatted_text[1] == "")

   input = { "Thisisoneverylongword", "some more words" }
   formatted_text = text.format(
      input,
      line_width,
      hyphenate,
      hyphenate_minimum_gap,
      hyphenate_overflow,
      keep_indent,
      keep_prefixes
   )
   assert(#formatted_text == 4, "Got length " .. #formatted_text)
   assert(formatted_text[1] == "Thisisoneverylongword", "Got " .. formatted_text[1])
   assert(formatted_text[2] == "some")
   assert(formatted_text[3] == "more")
   assert(formatted_text[4] == "words")

   -- Check hyphenate overflow.
   line_width = 5
   hyphenate_overflow = true
   formatted_text = text.format(
      input,
      line_width,
      hyphenate,
      hyphenate_minimum_gap,
      hyphenate_overflow,
      keep_indent,
      keep_prefixes
   )
   assert(#formatted_text == 8)
   assert(formatted_text[1] == "This-")
   assert(formatted_text[2] == "ison-")
   assert(formatted_text[3] == "ever-")
   assert(formatted_text[4] == "ylon-")
   assert(formatted_text[5] == "gword")
   assert(formatted_text[6] == "some")
   assert(formatted_text[7] == "more")
   assert(formatted_text[8] == "words")
   line_width = 18
   formatted_text = text.format(
      input,
      line_width,
      hyphenate,
      hyphenate_minimum_gap,
      hyphenate_overflow,
      keep_indent,
      keep_prefixes
   )
   assert(#formatted_text == 3)
   assert(formatted_text[1] == "Thisisoneverylong-")
   assert(formatted_text[2] == "word some more")
   assert(formatted_text[3] == "words")

   -- keep_indent functionality checks.
   input = { "  Some simple ", "       words" }
   line_width = 5
   hyphenate = true
   hyphenate_minimum_gap = 2
   hyphenate_overflow = false
   keep_indent = true
   formatted_text = text.format(
      input,
      line_width,
      hyphenate,
      hyphenate_minimum_gap,
      hyphenate_overflow,
      keep_indent,
      keep_prefixes
   )
   assert(#formatted_text == 7, "Got length " .. #formatted_text)
   assert(formatted_text[1] == "  So-")
   assert(formatted_text[2] == "  me")
   assert(formatted_text[3] == "  si-")
   assert(formatted_text[4] == "  mp-")
   assert(formatted_text[5] == "  le")
   assert(formatted_text[6] == "  wo-")
   assert(formatted_text[7] == "  rds")

   input = { "  Some simpley ", "       words" }
   line_width = 8
   hyphenate = true
   hyphenate_minimum_gap = 2
   hyphenate_overflow = false
   keep_indent = true
   formatted_text = text.format(
      input,
      line_width,
      hyphenate,
      hyphenate_minimum_gap,
      hyphenate_overflow,
      keep_indent,
      keep_prefixes
   )
   assert(#formatted_text == 4, "Got length " .. #formatted_text)
   assert(formatted_text[1] == "  Some")
   assert(formatted_text[2] == "  simpl-")
   assert(formatted_text[3] == "  ey wo-")
   assert(formatted_text[4] == "  rds")

   input = { "  Some simple ", "       words" }
   line_width = 50
   hyphenate = true
   hyphenate_minimum_gap = 2
   hyphenate_overflow = true
   formatted_text = text.format(
      input,
      line_width,
      hyphenate,
      hyphenate_minimum_gap,
      hyphenate_overflow,
      keep_indent,
      keep_prefixes
   )
   assert(#formatted_text == 1)
   assert(formatted_text[1] == "  Some simple words")

   keep_prefixes = { "# ", "-- ", "Some ", "simple" }
   keep_indent = true
   line_width = 10
   hyphenate = false
   hyphenate_overflow = false
   formatted_text = text.format(
      input,
      line_width,
      hyphenate,
      hyphenate_minimum_gap,
      hyphenate_overflow,
      keep_indent,
      keep_prefixes
   )
   assert(#formatted_text == 2, "Got length " .. #formatted_text)
   assert(formatted_text[1] == "  Some simple")
   assert(formatted_text[2] == "  Some words")

   keep_prefixes = { "# ", "-- ", "Some ", "simple" }
   line_width = 10
   hyphenate = false
   hyphenate_overflow = true
   formatted_text = text.format(
      input,
      line_width,
      hyphenate,
      hyphenate_minimum_gap,
      hyphenate_overflow,
      keep_indent,
      keep_prefixes
   )
   assert(#formatted_text == 5, "Got length " .. #formatted_text)
   assert(formatted_text[1] == "  Some si-")
   assert(formatted_text[2] == "  Some mp-")
   assert(formatted_text[3] == "  Some le")
   assert(formatted_text[4] == "  Some wo-")
   assert(formatted_text[5] == "  Some rds")
end

function M.run()
   test_get_whitespace_prefix()
   test_clear_whitespace_prefixes()
   test_get_prefix()
   test_unravel_lines()
   test_hyphenise()
   test_format()
end

return M
