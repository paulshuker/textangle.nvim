---@class text
local M = {}

-- Place hyphens in the given string so it can be split between lines and respect the maximum width
-- for each line.
--- @param input string String to add hyphens to.
--- @param max_width integer Maximum width of each line.
--- @param first_width integer? Maximum width for the first line. Default: same as max_width.
--- @return table hyphen_input. An array of lines where the given input is split using hyphens.
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

-- Format the given text into fixed-width paragraphs.
---@param input table An array of input text. Each item in the table is a line.
---@param opts table A table of options to format text with. Contains:
---   line_length [opt=88] integer. The maximum width of each line.
---   hyphenate [opt=true] boolean. Allow hyphenation of long words. See hyphenate_minimum_gap.
---   hyphenate_minimum_gap [opt=10] integer. If hyphenate is true and the gap left by moving the
---      next word over to the next line is greater than hyphenate_minimum_gap, then the word is
---      hyphenated to reach line_length. If hyphenate is true and this is 0, then every word is
---      always hyphenated to reach exactly line_length widths.
---   hyphenate_overflow [opt=true] boolean. Hyphenate a word if the word is greater than the
---      line_length. If false, then the line will be forced to exceed the line_length.
---@return table formatted_text. Formatted text. Each value in the array is a line of text.
function M.format(input, opts)
   assert(type(input) == "table")
   assert(#input > 0)
   assert(type(opts) == "table")
   opts.line_length = opts.line_length or 88
   opts.hyphenate = opts.hyphenate or true
   opts.hyphenate_minimum_gap = opts.hyphenate_minimum_gap or 10
   opts.hyphenate_overflow = opts.hyphenate_overflow or true
   -- TODO: Support "persistent suffix" options for things like repeated single-line comments.

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
      -- Check for edge cases first.
      if
         opts.hyphenate
         and (#word + #new_line) > opts.line_length
         and (opts.line_length - #new_line) >= opts.hyphenate_minimum_gap
      then
         -- Hyphenate the word.
         local hyphened_word = M.hyphenise(word, opts.line_length, opts.line_length - #new_line)
         table.insert(formatted_text, new_line .. hyphened_word[1])
         for i = 2, #hyphened_word - 1 do
            table.insert(formatted_text, hyphened_word[i])
         end
         new_line = hyphened_word[#hyphened_word]
         goto continue
      end

      if opts.hyphenate_overflow and new_line == "" and #word > opts.line_length then
         -- Split the word up between lines using a hyphen.
         local hyphened_word = M.hyphenise(word, opts.line_length)
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
      if length_required <= opts.line_length then
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
