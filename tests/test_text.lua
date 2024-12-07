---@class text
text = require("lua.textangle.text")

---@class test_text
local M = {}

function M.run()
   local input = { "" }
   local opts = { line_length = 20, hyphenate_overflow = false }

   -- Empty input checks.
   local formatted_text = text.format(input, opts)
   assert(#formatted_text == 1)
   assert(type(formatted_text[1]) == "string")
   assert(formatted_text[1] == "")
   input = { "", "   ", "" }
   formatted_text = text.format(input, opts)
   assert(#formatted_text == 1)
   assert(type(formatted_text[1]) == "string")
   assert(formatted_text[1] == "")
end

return M
