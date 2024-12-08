local api = vim.api

-- @class options
local M = {}

local OPTION_TYPES = {
   line_width = "number",
   hyphenate = "boolean",
   hyphenate_minimum_gap = "number",
   hyphenate_overflow = "boolean",
}

function M.is_valid_option_name(opt_name)
   for name, _ in pairs(OPTION_TYPES) do
      if opt_name == name then
         return true
      end
   end
   return false
end

-- Check if the given options have any unknown option names.
---@param opts table? User-specified options. Default: no options specified.
---@return boolean has_unknown. Whether the given options contains an unknown option name.
function M.has_unknown_option(opts)
   opts = opts or {}
   for opt_name, _ in pairs(opts) do
      if not M.is_valid_option_name(opt_name) then
         return true
      end
   end
   return false
end

-- Ensure every option is the expected type. If not, an error is printed.
---@param opts table User-specified options.
---@return boolean valid. Whether the options types were all valid or not.
function M.are_valid_types(opts)
   assert(type(opts) == "table")

   for opt_name, opt_type in pairs(OPTION_TYPES) do
      if opts[opt_name] == nil then
         goto continue
      end
      if type(opts[opt_name]) ~= opt_type then
         api.nvim_err_writeln(
            "Unexpected type " .. type(opts[opt_name]) .. " for option " .. opt_name
         )
         return false
      end
      ::continue::
   end
   return true
end

return M
