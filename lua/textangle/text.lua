---@class Text
local M = {}

---Split the given text up with hyphens.
-- Place hyphens in the given string so it can be split between lines and respect the maximum width
-- for each line.
---@param input string String to add hyphens to.
---@param max_width integer Maximum width of each line.
---@param first_width integer? Maximum width for the first line. Default: same as max_width.
---@return string[] hyphen_input. An array of lines where the given input is split using hyphens.
function M.hyphenise(input, max_width, first_width)
   first_width = first_width or max_width

   assert(type(input) == "string")
   assert(type(max_width) == "number")
   assert(math.floor(max_width) == max_width)
   assert(type(first_width) == "number")
   assert(math.floor(first_width) == first_width)

   local max_width_sub_one = max_width - 1

   local output = {}
   local line_count = math.ceil((#input + max_width_sub_one - first_width) / max_width_sub_one)
   -- Line count must be at least 1.
   line_count = math.max(line_count, 1)

   for i = 1, line_count do
      -- local index_min = math.max((i - 2) * (max_width - 1) + 1, 1)
      local index_min = nil
      local index_max = nil
      local on_first_line = i == 1
      local on_final_line = i == line_count

      if on_first_line then
         index_min = 1
         index_max = first_width - 1
      else
         index_min = first_width + math.max((i - 2) * max_width_sub_one, 0)
         index_max = first_width - 1 + (i - 1) * max_width_sub_one
      end

      if on_final_line then
         -- No hyphen required on the final line.
         index_max = #input
      end

      local new_line = string.sub(input, index_min, index_max)
      if not on_final_line then
         new_line = new_line .. "-"
      end
      table.insert(output, new_line)
   end

   return output
end

--- Format the given text into fixed-width paragraphs.
---@param input string[] An array of input text. Each item in the table is a line.
---@param line_width integer The maximum width of each line.
---@param hyphenate boolean Allow hyphenation of long words. See hyphenate_minimum_gap.
---@param hyphenate_minimum_gap integer If hyphenate is true and the gap left by moving the next
---   word over to the next line is greater than hyphenate_minimum_gap, then the word is hyphenated
---   to reach line_width. If hyphenate is true and this is 0, then every word is always hyphenated
---   to reach exactly line_width widths.
---@param hyphenate_overflow boolean Hyphenate a word if the word is greater than the line_width.
---   If false, then the line will be forced to exceed the line_width.
---@return string[] formatted_text. Formatted text. Each value in the array is a line of text.
function M.format(input, line_width, hyphenate, hyphenate_minimum_gap, hyphenate_overflow)
   assert(type(input) == "table")
   assert(#input > 0)
   assert(type(line_width) == "number")
   assert(type(hyphenate) == "boolean")
   assert(type(hyphenate_minimum_gap) == "number")
   assert(type(hyphenate_overflow) == "boolean")
   -- TODO: Support "keep_suffixes" option for things like repeated single-line code comments.
   -- TODO: Support "keep_indents" option so a formatted line remained indented.

   -- First, unravel the given text into a single string.
   -- Every word is separated by a single space.
   local unravelled_text = ""
   local first_word = false

   for _, text_line in ipairs(input) do
      assert(type(text_line) == "string")

      for word in string.gmatch(text_line, "%S+") do
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
   for word in string.gmatch(unravelled_text, "%S+") do
      -- Check for edge cases first.
      if
         hyphenate
         and (#word + #new_line) > line_width
         and (line_width - #new_line) >= hyphenate_minimum_gap
      then
         -- Hyphenate the word.
         local hyphened_word = M.hyphenise(word, line_width, line_width - #new_line)
         table.insert(formatted_text, new_line .. hyphened_word[1])
         for i = 2, #hyphened_word - 1 do
            table.insert(formatted_text, hyphened_word[i])
         end
         new_line = hyphened_word[#hyphened_word]
         goto continue
      end

      if hyphenate_overflow and new_line == "" and #word > line_width then
         -- Split the word up between lines using a hyphen.
         local hyphened_word = M.hyphenise(word, line_width)
         for i = 1, #hyphened_word - 1 do
            table.insert(formatted_text, hyphened_word[i])
         end
         new_line = hyphened_word[#hyphened_word]
         goto continue
      end

      local first_word_of_line = #new_line == 0
      if first_word_of_line then
         new_line = new_line .. word
         goto continue
      end

      local length_required = #word + #new_line + 1
      if length_required <= line_width then
         new_line = new_line .. " " .. word
      else
         table.insert(formatted_text, new_line)
         new_line = word
      end
      ::continue::
   end

   table.insert(formatted_text, new_line)

   return formatted_text
end

return M
