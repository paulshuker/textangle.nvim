---@class text
local M = {}

-- Format the given text into fixed-width paragraphs.
---@param input table An array of input text. Each item in the table is a line.
---@param opts table A table of options to format text with. Contains:
---   line_length (integer). The maximum width of each line.
---   hyphenate_overflow (boolean). Hyphenate a word if the word is greater than the line_length.
---      If false, then the line will exceed line_length.
---@return table formatted_text. Formatted text. Each value in the array is a line of text.
function M.format(input, opts)
   assert(type(input) == "table")
   assert(type(opts) == "table")
   assert(opts.line_length ~= nil)
   assert(opts.hyphenate_overflow ~= nil)

   -- First, unravel the given text into a single string.
   -- Every word is separated by a single space.
   local unravelled_text = ""
   local first_word = false

   for _, text_line in ipairs(input) do
      assert(type(text_line) == "string")

      for word in string.gmatch(text_line, "%a+") do
         if not first_word then
            unravelled_text = unravelled_text .. " "
         end

         unravelled_text = unravelled_text .. word
         first_word = false
      end
   end

   -- Now order the text contents into separate lines.
   local formatted_text = {}
   local new_line = ""
   for word in string.gmatch(unravelled_text, "%a+") do
      if #word <= opts.line_length then
         new_line = new_line .. word
      end
   end
   table.insert(formatted_text, new_line)

   return formatted_text
end

return M
