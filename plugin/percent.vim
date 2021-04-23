" Percent encode a URI, i.e., replace characters with percent codes as required.
"
" Maintainer: Daniel Wennberg
"
" Loosely based on
" http://www.danielbigham.ca/cgi-bin/document.pl?mode=Display&DocumentID=1053

let g:percent_loaded = 1

" the default set of permitted characters includes reserved characters that don't have
" to be encoded when used in the path component, as well as the / delimiter.
let g:percent_defaults = {
      \ 'permitted': "!$&'()*+,/:;=@",
      \ 'filetypes': ['html', 'markdown', 'pandoc'],
      \}

" use percent#decode as includeexpr to make gf work on local links
let s:ftpattern = join(percent#get('filetypes'), ",")

augroup percent
  autocmd!
  if s:ftpattern != ""
    execute "autocmd! FileType" s:ftpattern
          \ "setlocal includeexpr=percent#decode(v:fname)"
  endif
augroup END
