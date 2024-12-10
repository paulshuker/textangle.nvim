# textangle.nvim

A customisable neovim plugin to fix line widths to form paragraphs.

Works well out-the-box with plain text.

<!-- It can be [configured](#configuration) to work with single-line code comments. -->

## Install

On [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
   "paulshuker/textangle.nvim",
}
```

## Usage

Convert the text on the cursor's line into a paragraph by typing `:TextangleLine`.

## Configuration

In `init.lua`, setup textangle.

```lua
require("textangle").setup({})
```

Within the curly brackets, default options can be overwritten. The default options are:

```lua
{
   -- The maximum allowed width of each line.
   line_width = 88,
   -- Allow words to be hyphenated. A word will be hyphenated if placing the entire word on the next
   -- line leaves a whitespace greater than hyphenate_minimum_gap. The hyphen is placed at the end
   -- of lines.
   hyphenate = true,
   -- See hyphenate.
   hyphenate_minimum_gap = 10,
   -- If a word is longer than line_width, hyphenate it. If false, lines could overflow line_width.
   hyphenate_overflow = true,
}
```

## Advanced Configuration

You can call textangle setup multiple times. Each time it is called, all previous options are
forgotten. This way you can change the paragraph settings at any time in `.lua` configuration files.

### Change with file type

You can have different options depending on the programming language. For example,

```lua
-- Python files.
vim.api.nvim_create_autocmd({"BufEnter"}, {
   pattern = {"*.py"},
   command = "lua require('textangle').setup({ line_width = 120, hyphenate = false })",
})
-- Text and lua files.
vim.api.nvim_create_autocmd({"BufEnter"}, {
   pattern = {"*.txt", ".lua"},
   command = "lua require('textangle').setup({line_width = 100})",
})
-- Add more file types here.
```

See [neovim](https://neovim.io/doc/user/autocmd.html) for more details on auto commands.

