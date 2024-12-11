---@class Checker
local M = {}

M.OPTION_TYPES = {
   line_width = "number",
   hyphenate = "boolean",
   hyphenate_minimum_gap = "number",
   hyphenate_overflow = "boolean",
   keep_indent = "boolean",
   disable = "boolean",
}
M.OPTION_DEFAULTS = {
   line_width = 100,
   hyphenate = false,
   hyphenate_minimum_gap = 10,
   hyphenate_overflow = true,
   keep_indent = true,
   disable = false,
}

---Is a valid option name.
-- Whether the given option name is a valid option.
---@param opt_name string User-specified option name.
---@return boolean is_valid Whether the given option name is valid.
function M.is_valid_option_name(opt_name)
   for name, _ in pairs(M.OPTION_TYPES) do
      if opt_name == name then
         return true
      end
   end
   return false
end

---Find incorrect option names.
-- Check if the given options has at least one unknown option name.
---@param opts table? User-specified options. Default: none.
---@return boolean has_unknown, string unknown_name has_unknown is true when the given options
---contain an unknown option name. unknown_name is the name of the unknown option name.
function M.has_unknown_options(opts)
   opts = opts or {}
   for opt_name, _ in pairs(opts) do
      if not M.is_valid_option_name(opt_name) then
         return true, opt_name
      end
   end
   return false, ""
end

---Check option types.
-- Ensure every user option is the expected type. If not, an error is printed.
---@param opts table User-specified options.
---@return boolean valid, string msg Whether the options types were all valid or not. msg is the
---given error message if valid was false. msg is a blank string if valid is true.
function M.are_valid_types(opts)
   assert(type(opts) == "table")

   for opt_name, opt_type in pairs(M.OPTION_TYPES) do
      if opts[opt_name] == nil then
         goto continue
      end
      if type(opts[opt_name]) ~= opt_type then
         local msg = "Unexpected type " .. type(opts[opt_name]) .. " for option " .. opt_name
         return false, msg
      end
      ::continue::
   end
   return true, ""
end

---Place default option values for unset options.
---@param opts table User-specified options.
---@return table all_opts All options.
function M.fill_options(opts)
   local output = {}
   for opt_name, opt_default in pairs(M.OPTION_DEFAULTS) do
      output[opt_name] = opt_default
   end
   for opt_name, opt_value in pairs(opts) do
      output[opt_name] = opt_value
   end
   return output
end

return M
