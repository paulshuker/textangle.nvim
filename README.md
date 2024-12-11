# textangle.nvim

A customisable neovim plugin to fix line widths to form paragraphs.

Works well out-the-box with plain text.

<!-- It can be [configured](#configuration) to work with single-line code comments. -->

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

Then, format text on the cursor's line by typing `:TextangleLine`. You can also keymap it. For
example, to `gl`:

```lua
vim.api.nvim_set_keymap("n", "gl", "<cmd>TextangleLine<CR>", { noremap = true })
```

You can format text using visual line mode, like by typing `gk`:

```lua
vim.api.nvim_set_keymap(
  "x",
  "gk",
  "<cmd>lua require('textangle').format_visual_line()<CR>",
  { noremap = true }
)
```

## Configuration

Within the curly brackets, default options can be overwritten. The default options are:

```lua
{
   -- The maximum allowed width of each line.
   line_width = 100,
   -- Allow words to be hyphenated. A word will be hyphenated if placing the entire word
   -- on the next line leaves a whitespace greater than hyphenate_minimum_gap. The hyphen
   -- is placed at the end of lines.
   hyphenate = false,
   -- See hyphenate.
   hyphenate_minimum_gap = 10,
   -- If a word is longer than line_width, hyphenate it. If false, large words could
   -- overflow.
   hyphenate_overflow = true,
   -- Repeat the indent found on the first line on every line. An indent can be tabs or
   -- spaces.
   keep_indent = true,
   -- When disabled, textangle will silently do nothing whenever called.
   disable = false,
}
```

## Advanced Configuration

You can call setup multiple times. Each time it is called, all previous options are forgotten. This
way you can change the paragraph settings at any time.

### Change with file type

You can have different options depending on the file. For example,

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

See [neovim](https://neovim.io/doc/user/autocmd.html) for more details on auto commands, like
changing formatting based on the file's full path.

### "What is a word?"

Words are simply a series of letters/symbols given to textangle. If there were spaces, tabs or a new
line in between the letters/symbols, then it would be considered two separate words. Hyphens already
placed by the user in text are preserved.

