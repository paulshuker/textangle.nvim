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
   -- line leaves a whitespace greater than hyphenate_minimum_gap.
   hyphenate = true,
   -- See hyphenate.
   hyphenate_minimum_gap = 10,
   -- If a word is longer than line_width, hyphenate the word. If false, lines could overflow
   -- line_width.
   hyphenate_overflow = true,
}
```

