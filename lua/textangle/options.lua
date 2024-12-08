local api = vim.api

---@class options
local M = {}

local OPTION_DEFAULTS = {
   line_width = 88,
   hyphenate = true,
   hyphenate_minimum_gap = 10,
   hyphenate_overflow = true,
}

function M.is_valid_option_name(opt_name)
   for name, _ in pairs(OPTION_DEFAULTS) do
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

-- Parse options. Any user specified options overwrite the default values.
---@param opts table? User-specified options. Default: no options specified.
---@return table all_options. All options with default values set.
function M.parse(opts)
   opts = opts or {}

   -- Set some options to defaults.
   local opts_all = {}
   for opt_name, opt_default in pairs(OPTION_DEFAULTS) do
      opts_all[opt_name] = opts[opt_name]

      if opts_all[opt_name] == nil then
         opts_all[opt_name] = opt_default
      end
   end

   return opts_all
end

-- Ensure every option is the expected type. If not, an error is printed.
---@param opts table Parsed options.
---@return boolean valid. Whether the options types were all valid or not.
function M.are_valid_types(opts)
   assert(type(opts) == "table")

   for opt_name, opt_default in pairs(OPTION_DEFAULTS) do
      if type(opts[opt_name]) ~= type(opt_default) then
         api.nvim_err_writeln(
            "Unexpected type " .. type(opts[opt_name]) .. " for option " .. opt_name
         )
         return false
      end
   end
   return true
end

return M
