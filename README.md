# textangle.nvim

![](https://img.shields.io/github/check-runs/paulshuker/textangle.nvim/main?logo=github&logoColor=white&label=Tests)
![](https://img.shields.io/badge/Lua-%252357A143?logo=lua&logoColor=white&labelColor=%232C2D72&color=%232C2D72)
[![](https://img.shields.io/badge/Neovim-%252357A143?logo=neovim&logoColor=white&labelColor=%2300563B&color=%2300563B)](https://neovim.io/)

A customisable neovim plugin to fix line widths and form paragraphs.

Neovim's [textwidth](https://neovim.io/doc/user/options.html#'textwidth') is already
great! This plugin will give you slightly more control over paragraphs. Textangle does not
rely on the LSP. But, it can still reformat single-line code comments.

## Install

With [lazy.nvim](https://github.com/folke/lazy.nvim),

```lua
{
   "paulshuker/textangle.nvim",
}
```

## Usage

In `init.lua`, setup textangle.

```lua
require("textangle").setup({})
```

Then, format text on the cursor's line by typing `:TextangleLine`. You can also keymap it.
For example, to `gl`:

```lua
vim.api.nvim_set_keymap("n", "gl", "<cmd>TextangleLine<CR>", { noremap = true })
```

You can format text using visual line mode, I set it to key map `gk`:

```lua
vim.api.nvim_set_keymap(
  "x",
  "gk",
  "<cmd>lua require('textangle').format_visual_line()<CR>",
  { noremap = true }
)
```

## Configuration

During setup, within the curly brackets, any default options can be overwritten. The
default options are:

```lua
{
   -- The maximum width of each line. When set to -1, Neovim's
   -- [textwidth](https://neovim.io/doc/user/options.html#'textwidth') is used. See the
   -- [editorconfig](https://neovim.io/doc/user/editorconfig.html) for ways to configure
   -- textwidth project-wise.
   line_width = -1,
   -- Allow words to be hyphenated. A word will be hyphenated if placing the entire word
   -- on the next line leaves a whitespace greater than hyphenate_minimum_gap. The hyphen
   -- is placed at the end of lines.
   hyphenate = false,
   -- See hyphenate.
   hyphenate_minimum_gap = 10,
   -- If a word is longer than line_width, hyphenate it. If false, words longer than
   -- line_width will overflow.
   hyphenate_overflow = true,
   -- Repeat the indent found on the first line on every line. An indent can be tabs or
   -- spaces.
   keep_indent = true,
   -- If the first given line contains one of these prefixes (after any optional
   -- indentation), then the prefix is repeated on every line. This is useful for
   -- single-line comments. Whitespace must match too. Set to { } to disable.
   kept_prefixes = { "-- ", "// ", "# " },
   -- When disabled, textangle will silently do nothing whenever called.
   disable = false,
}
```

## Advanced Configuration

You can call setup multiple times. Each time it is called, all previous options are
forgotten. This way you can change the paragraph settings at any time.

### Change settings with file type

If you just need to change the line_width based on file type, set `max_line_length` in a
[.editorconfig](https://neovim.io/doc/user/editorconfig.html) file in your working
directory and set textangle linewidth to -1 (default).

But, if you need finer tuning like hyphenation, use auto commands in your neovim config.
For example,

```lua
-- Python files.
vim.api.nvim_create_autocmd({ "BufEnter" }, {
   pattern = { "*.py" },
   command = "lua require('textangle').setup({ line_width = 120, hyphenate = false })",
})
-- Text and lua files.
vim.api.nvim_create_autocmd({ "BufEnter" }, {
   pattern = { "*.txt", "*.lua" },
   command = "lua require('textangle').setup({ line_width = 100 })",
})
-- Do not format csv files.
vim.api.nvim_create_autocmd({ "BufEnter" }, {
   pattern = { "*.csv" },
   command = "lua require('textangle').setup({ disable = true })",
})
-- Add more file types here.
```

See [autocmd](https://neovim.io/doc/user/autocmd.html) for more details on auto commands,
like changing formatting based on the file's full path.

### "What is a word?"

Words are simply a series of letters/symbols given to textangle. If there were spaces,
tabs or a new line in between the letters/symbols, then it would be considered two
separate words. Hyphens already placed by the user in text are preserved.

