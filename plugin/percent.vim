" Percent encode a URI, i.e., replace characters with percent codes as required.
"
" Maintainer: Daniel Wennberg
"
" Loosely based on
" http://www.danielbigham.ca/cgi-bin/document.pl?mode=Display&DocumentID=1053

let g:percent_loaded = 1

" The default set of permitted characters includes reserved characters that don't have
" to be encoded when used in the path component, as well as the / delimiter.
if !exists('g:percent_permitted')
  let g:percent_permitted = "!$&'()*+,/:;=@"
endif

" Use percent#decode as includeexpr to make gf work on local links
let s:filetypes = get(g:, 'percent_filetypes', ['html', 'markdown', 'pandoc'])
let s:filetypes_pattern = join(s:filetypes, ",")

augroup percent
  autocmd!
  if s:filetypes_pattern != ""
    execute "autocmd! FileType" s:filetypes_pattern
          \ "setlocal includeexpr=percent#decode(v:fname)"
  endif
augroup END
