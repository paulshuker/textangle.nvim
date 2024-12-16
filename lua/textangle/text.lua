---@class Text
local M = {}

---Get the whitespace found at the start of the given string, if any.
-- Whitespace can be tabs or spaces.
---@param input_line string The given string.
---@return string whitespace_prefix The whitespace at the beginning of input_line.
function M.get_whitespace_prefix(input_line)
   local output = ""
   for i = 1, #input_line do
      local char = input_line:sub(i, i)
      if char == " " or char == "\t" then
         output = output .. char
      else
         break
      end
   end
   return output
end

---Clear all whitespace prefixes from all strings.
---@param input string[] The given lines of text.
---@return string[] output Removed whitespace prefix text copy.
function M.clear_whitespace_prefixes(input)
   local output = {}

   for line_i, input_line in ipairs(input) do
      output[line_i] = ""
      for char_i = 1, #input_line do
         local char = input_line:sub(char_i, char_i)
         if char == " " or char == "\t" then
            goto next_char
         else
            output[line_i] = input_line:sub(char_i - #input_line - 1)
            goto next_line
         end
         ::next_char::
      end
      ::next_line::
   end

   return output
end

---Find any prefix at the start of the given line.
---@param input_line string The given text.
---@param prefixes string[] Valid prefixes.
---@return string found_prefix The found prefix. If no prefix is matched, then an empty string is
---   returned.
function M.get_prefix(input_line, prefixes)
   for _, prefix in ipairs(prefixes) do
      if string.sub(input_line, 1, #prefix) == prefix then
         return prefix
      end
   end

   return ""
end

---Unravel lines of text into one string.
-- All lines of text are appended together, preserving their order in the input array. Each phrase
-- is separated by a single whitespace.
---@param input string[] Lines of text.
---@return string output Unravelled text.
function M.unravel_lines(input)
   local output = ""
   local first_line = true

   for _, input_line in ipairs(input) do
      assert(type(input_line) == "string")

      if not first_line then
         output = output .. " "
      end
      -- Remove tabs.
      output = output .. string.gsub(input_line, "\t", " ")
      first_line = false
   end

   -- Remove large whitespace in favour of a single whitespace.
   output = string.gsub(output, "%s+", " ")

   return output
end

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
---@param keep_indent boolean Repeat the indentation found on the first line on all formatted lines
---   of text.
---@return string[] formatted_text. Formatted text. Each value in the array is a line of text.
function M.format(
   input,
   line_width,
   hyphenate,
   hyphenate_minimum_gap,
   hyphenate_overflow,
   keep_indent,
   keep_prefixes
)
   assert(type(input) == "table")
   assert(#input > 0)
   assert(type(line_width) == "number")
   assert(type(hyphenate) == "boolean")
   assert(type(hyphenate_minimum_gap) == "number")
   assert(type(hyphenate_overflow) == "boolean")
   assert(type(keep_indent) == "boolean")
   assert(type(keep_prefixes) == "table")

   local prefix = ""
   if keep_indent then
      prefix = M.get_whitespace_prefix(input[1])
   end

   input = M.clear_whitespace_prefixes(input)

   local first_line = input[1]
   local keep_prefix = M.get_prefix(first_line, keep_prefixes)
   prefix = prefix .. keep_prefix
   -- Remove kept prefixes while formatting. It will be re-added later.
   for line_index, input_line in ipairs(input) do
      if string.sub(input_line, 1, #keep_prefix) == keep_prefix then
         input[line_index] = string.sub(input_line, -(#input_line - #keep_prefix))
      end
   end

   line_width = line_width - #prefix

   local err_msg = 'Prefix "' .. prefix .. '" too long for line_width ' .. line_width + #prefix
   assert(line_width > 1, err_msg)

   -- Unravel the given text into a single string.
   -- Every word is separated by a single space.
   local unravelled_text = M.unravel_lines(input)

   -- Now order the text contents into separate lines.
   ---@type string[]
   local formatted_text = {}
   local new_line = ""
   for word in string.gmatch(unravelled_text, "%S+") do
      ::word_start::

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
         new_line = hyphened_word[#hyphened_word] .. " "
         goto continue
      end

      local first_word_of_line = #new_line == 0

      if hyphenate_overflow and first_word_of_line and #word > line_width then
         -- Split the word up between lines using a hyphen.
         local hyphened_word = M.hyphenise(word, line_width)
         for i = 1, #hyphened_word - 1 do
            table.insert(formatted_text, hyphened_word[i])
         end
         new_line = hyphened_word[#hyphened_word] .. " "
         goto continue
      end

      first_word_of_line = #new_line == 0
      local length_required = #word + #new_line

      if first_word_of_line or (length_required <= line_width) then
         new_line = new_line .. word .. " "
         goto continue
      else
         -- Move to the next line, then the word is checked again from the start of the for loop.
         table.insert(formatted_text, new_line)
         new_line = ""
         goto word_start
      end
      ::continue::
   end

   if #formatted_text == 0 or new_line ~= "" then
      table.insert(formatted_text, new_line)
   end

   -- Remove trailing spaces.
   for i, formatted_line in ipairs(formatted_text) do
      if formatted_line:sub(-1) == " " then
         formatted_text[i] = formatted_line:sub(1, -2)
      end
   end

   -- Insert prefix, if there is one, on every formatted line.
   for i, formatted_line in ipairs(formatted_text) do
      formatted_text[i] = prefix .. formatted_line
   end

   return formatted_text
end

return M
