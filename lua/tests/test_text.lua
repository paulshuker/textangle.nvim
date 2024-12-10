---@class test_text
local M = {}

---@class Text
local text = require("textangle.text")

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
   -- Empty input checks.
   local formatted_text =
      text.format(input, line_width, hyphenate, hyphenate_minimum_gap, hyphenate_overflow)
   assert(#formatted_text == 1, "Got length " .. #formatted_text)
   assert(type(formatted_text[1]) == "string")
   assert(formatted_text[1] == "")
   input = { "", "   ", "" }
   formatted_text =
      text.format(input, line_width, hyphenate, hyphenate_minimum_gap, hyphenate_overflow)
   assert(#formatted_text == 1)
   assert(type(formatted_text[1]) == "string")
   assert(formatted_text[1] == "")

   input = { "Thisisoneverylongword", "some more words" }
   formatted_text =
      text.format(input, line_width, hyphenate, hyphenate_minimum_gap, hyphenate_overflow)
   assert(#formatted_text == 4, "Got length " .. #formatted_text)
   assert(formatted_text[1] == "Thisisoneverylongword", "Got " .. formatted_text[1])
   assert(formatted_text[2] == "some")
   assert(formatted_text[3] == "more")
   assert(formatted_text[4] == "words")

   -- Check hyphenate overflow.
   line_width = 5
   hyphenate_overflow = true
   formatted_text =
      text.format(input, line_width, hyphenate, hyphenate_minimum_gap, hyphenate_overflow)
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
   formatted_text =
      text.format(input, line_width, hyphenate, hyphenate_minimum_gap, hyphenate_overflow)
   assert(#formatted_text == 3)
   assert(formatted_text[1] == "Thisisoneverylong-")
   assert(formatted_text[2] == "word some more")
   assert(formatted_text[3] == "words")
end

function M.run()
   test_hyphenise()
   test_format()
end

return M
