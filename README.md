# vim-percent: Percent-encode and -decode text in vim

Here's a small vim-plugin to handle percent encoding and decoding of text to form valid URI components.

Percent-encoding means replacing special characters with their literal byte values written out as `%XX`, where `X` represents a hexadecimal digit. For example, a space becomes `%20`. See <https://en.wikipedia.org/wiki/Percent-encoding> for details.

The functionality of this plugin is exposed through the functions `Percent{Encode,Decode}`, which take a single string as argument and returns the corresponding encoded/decoded string. Perhaps more usefully, the plugin also provides operator functions `Percent{Encode,Decode}Op`, which can be mapped to operators that replace a text object or selection with its percent encoded/decoded counterpart. To make use of this, put something like the following in your `.vimrc`:

```vim
" Percent encoding/decoding
nmap <silent> <expr> <Leader>ne PercentEncodeOp()
vmap <silent> <expr> <Leader>ne PercentEncodeOp()
nmap <silent> <expr> <Leader>nd PercentDecodeOp()
vmap <silent> <expr> <Leader>nd PercentDecodeOp()
```

Hit `<Leader>ndi(` inside the URL part of a percent-encoded markdown link to see the operator in action.

## Fixing `gf`

The built-in `gf` keybinding for opening the file under the cursor does not decode percent-encoded filenames, and hence fails to open local links in HTML, markdown, etc., if the filename contains special characters. `vim-percent` fixes this problem by setting `includeexpr` for selected file types.

Note that some plugins, such as [vim-pandoc](https://github.com/vim-pandoc/vim-pandoc), may override `gf` in a way that does not use `includeexpr`, rendering `vim-percent`s fix useless for the affected file types. The recommended workaround is to disable this behavior from the implicated plugin, i.e., adding something like `let g:pandoc#modules#disabled = ["hypertext"]` or `let g:pandoc#hypertext#use_default_mappings = 0` to your `.vimrc`.

## Parameters

* `g:percent_permitted_reserved`: A string of reserved URI characters that should not be percent encoded. Default: `"!$&'()*+,/:;=@"` (these are the reserved characters that do not require encoding when used in the path component of a URI). These come on top of unreserved characters, comprising digits, ASCII letters, and `-._~`, which are never encoded. Changing the value of this parameter takes effect from the next encoding operation, whether by function call or operator action.
* `g:percent_filetypes`: Lists the file types for which `includeexpr` should be set such that `gf` can be used to open local links with special characters. Default: `['html', 'markdown', 'pandoc']`. Changing the value of this parameter takes effect after reloading the plugin.
* The plugin exports the variable `g:percent_unreserved_nonalnum`, which is a string containing the non-alphanumeric unreserved characters `-._~`. This can be used in other plugins, scripts and configuration files, but should not be modified.
