M = {}

---@class Text
local text = require("lua.textangle.text")

local ITERATIONS = 100000
local INPUT = {
   " \t  Lots of words!    And such ",
   " sdsd ",
   "fsdhfdv",
   "22@#@!%FDFDF",
   "  fsfs sfssdsd   sddd\tdfdfd",
}

local function benchmark_unravel_lines()
   local start_time = os.clock()
   for _ = 1, ITERATIONS do
      text.unravel_lines(INPUT)
   end
   local time_taken = os.clock() - start_time
   assert(time_taken < 1)
end

local function benchmark_format()
   local line_width = 10
   local hyphenates = { true, false }
   local hyphenate_minimum_gaps = { 0, 2, 20 }
   local hyphenate_overflows = { true, false }
   local keep_indents = { true, false }
   local keep_prefixeses = { {}, { "Lot" } }

   -- Run with various options.
   for _, hyphenate in ipairs(hyphenates) do
      for _, hyphenate_minimum_gap in ipairs(hyphenate_minimum_gaps) do
         for _, hyphenate_overflow in ipairs(hyphenate_overflows) do
            for _, keep_indent in ipairs(keep_indents) do
               for _, keep_prefixes in ipairs(keep_prefixeses) do
                  local start_time = os.clock()
                  for _ = 1, ITERATIONS do
                     text.format(
                        INPUT,
                        line_width,
                        hyphenate,
                        hyphenate_minimum_gap,
                        hyphenate_overflow,
                        keep_indent,
                        keep_prefixes
                     )
                  end
                  local time_taken = os.clock() - start_time
                  assert(time_taken < 5, "Failed with time taken " .. time_taken)
               end
            end
         end
      end
   end
end

function M.run()
   benchmark_unravel_lines()
   benchmark_format()
end

return M
