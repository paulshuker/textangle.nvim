local M = {}

local api = vim.api
---@class Checker
local checker = require("textangle.checker")
---@class Text
local text = require("textangle.text")

local function run_format(input_text, all_opts)
   return text.format(
      input_text,
      all_opts.line_width,
      all_opts.hyphenate,
      all_opts.hyphenate_minimum_gap,
      all_opts.hyphenate_overflow
   )
end

---Format the text on the cursor's line.
local function format_on_line()
   -- Gather the text on the cursor's line.
   local cursor_row = api.nvim_win_get_cursor(api.nvim_get_current_win())[1]
   local input_text = api.nvim_buf_get_lines(0, cursor_row - 1, cursor_row, true)

   local output_text = run_format(input_text, vim.g.textangle_all_opts)

   if output_text == input_text then
      return
   end

   -- Clear the line then insert formatted line(s).
   api.nvim_buf_set_lines(0, cursor_row - 1, cursor_row, true, {})
   api.nvim_buf_set_lines(0, cursor_row - 1, cursor_row - 1, true, output_text)
end

---Setup for textangle.
---@param opts table User-specified options.
function M.setup(opts)
   if type(opts) ~= "table" then
      api.nvim_err_writeln("opts must be a table, got " .. type(opts))
   end

   local has_unknown, unknown_name = checker.has_unknown_options(opts)
   if has_unknown then
      api.nvim_err_writeln("Unknown option '" .. unknown_name .. "' in textangle setup()")
      return
   end

   local valid_types, error_message = checker.are_valid_types(opts)
   if not valid_types then
      api.nvim_err_writeln(error_message)
      return
   end

   vim.g.textangle_all_opts = checker.fill_options(opts)

   api.nvim_create_user_command("TextangleLine", format_on_line, {})
end

return M
