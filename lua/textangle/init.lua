local M = {}

local api = vim.api
---@class Checker
local checker = require("textangle.checker")
---@class Text
local text = require("textangle.text")

local function is_disabled()
   return vim.g.textangle_all_opts.disable
end

---Whether the setup function was called already at least once.
---@return boolean was_called
local function was_setup_called()
   if vim.g.textangle_all_opts == nil then
      api.nvim_err_writeln("textangle's setup must be called first")
      return false
   end

   return true
end

local function run_format(input_text, all_opts)
   local line_width = all_opts.line_width
   if line_width == -1 then
      line_width = vim.o.tw
   end
   if line_width <= 1 then
      api.nvim_err_writeln("textangle line_width must be > 1 to format text")
      return nil
   end
   local output_text = text.format(
      input_text,
      line_width,
      all_opts.hyphenate,
      all_opts.hyphenate_minimum_gap,
      all_opts.hyphenate_overflow,
      all_opts.keep_indent
   )
   if output_text == input_text then
      return nil
   end

   return output_text
end

---Run text formatting between the given lines.
---@param line_start integer The starting line, starting from 0, inclusive.
---@param line_end integer The final line, starting from 0, inclusive.
local function format_lines(line_start, line_end)
   local input_text = api.nvim_buf_get_lines(0, line_start, line_end + 1, true)

   local output_text = run_format(input_text, vim.g.textangle_all_opts)

   if output_text == nil then
      return
   end

   -- Clear the line(s) then insert formatted line(s).
   api.nvim_buf_set_lines(0, line_start, line_end + 1, true, {})
   api.nvim_buf_set_lines(0, line_start, line_start, true, output_text)

   -- TODO: Position the cursor in a consistent manner after formatting text.
end

---Format the text on the cursor's line.
local function format_on_line()
   if not was_setup_called() then
      return
   end
   if is_disabled() then
      return
   end

   -- Gather the text on the cursor's line.
   local cursor_row = api.nvim_win_get_cursor(api.nvim_get_current_win())[1]

   format_lines(cursor_row - 1, cursor_row - 1)
end

---Run textangle on the selected visual line.
function M.format_visual_line()
   if not was_setup_called() then
      return
   end
   if is_disabled() then
      return
   end

   if api.nvim_get_mode().mode ~= "V" then
      api.nvim_err_writeln("textangle format_visual_line() must be run in visual-line mode")
      return
   end

   local start_line = vim.fn.line("v") - 1
   local end_line = vim.fn.line(".") - 1

   if start_line > end_line then
      start_line, end_line = end_line, start_line
   end

   format_lines(start_line, end_line)
end

---Setup textangle.
---@param opts table User-specified options.
---@see README.md configuration options.
function M.setup(opts)
   if type(opts) ~= "table" then
      api.nvim_err_writeln("opts must be a table, got type " .. type(opts))
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

   local all_opts = checker.fill_options(opts)

   -- Specific option value checks.
   if not checker.are_option_values_all_valid(all_opts) then
      return
   end

   vim.g.textangle_all_opts = all_opts

   api.nvim_create_user_command("TextangleLine", format_on_line, {})
end

return M
