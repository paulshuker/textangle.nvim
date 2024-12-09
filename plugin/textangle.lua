local VERSION_REQUIRED = "nvim-0.5.0"

if vim.fn.has(VERSION_REQUIRED) ~= 1 then
   vim.api.nvim_err_writeln("Example.nvim requires at least " .. VERSION_REQUIRED)
end
