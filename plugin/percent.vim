" Percent encode a URI, i.e., replace characters with percent codes as required. Loosely
" based on http://www.danielbigham.ca/cgi-bin/document.pl?mode=Display&DocumentID=1053
" The default set of permitted characters includes reserved characters that don't have
" to be encoded when used in the path component, as well as the / delimiter.
if !exists('g:percent_permitted_reserved')
  let g:percent_permitted_reserved = "!$&'()*+,/:;=@"
endif

" -._~ are always permitted. Decimal values: 45, 46, 95, 126
let g:percent_unreserved_nonalnum = "-._~"

function! PercentEncode(string)
  let l:chars = split(a:string, '\zs')
  return join(map(l:chars, 's:PercentEncodeCharacter(v:val)'), "")
endfunction

function! PercentDecode(string)
  return substitute(a:string, '\v\%(\x\x)', '\=printf("%c", "0x" . submatch(1))', 'g')
endfunction

function! s:PercentEncodeCharacter(char)
  " Digits and lower and uppercase ascii letters are always permitted
  let l:decimal = char2nr(a:char)
  if l:decimal >= 48 && l:decimal <= 57  " digits
    return a:char
  elseif l:decimal >= 65 && l:decimal <= 90 " uppercase letters
    return a:char
  elseif l:decimal >= 97 && l:decimal <= 122 " lowercase letters
    return a:char
  elseif a:char =~# '\v[' . g:percent_unreserved_nonalnum . g:percent_permitted_reserved . ']'
    return a:char
  endif
  let l:bytes = []
  for l:i in range(strlen(a:char))
    call add(l:bytes, printf("%%%02X", char2nr(strpart(a:char, l:i, 1))))
  endfor
  return join(l:bytes, "")
endfunction

" Define operator functions that can be mapped to encode/decode text in a buffer
function! PercentEncodeOp()
  execute "set operatorfunc=" . expand("<SID>") . "PercentEncodeOp"
  return 'g@'
endfunction

function! PercentDecodeOp(...)
  execute "set operatorfunc=" . expand("<SID>") . "PercentDecodeOp"
  return 'g@'
endfunction

function! s:PercentEncodeOp(type)
  return s:SubstituteTextobjOp(a:type, "PercentEncode")
endfunction

function! s:PercentDecodeOp(type)
  return s:SubstituteTextobjOp(a:type, "PercentDecode")
endfunction

function! s:SubstituteTextobjOp(type, func)
  let l:sel_save = &selection
  let l:visual_marks_save = [getpos("'<"), getpos("'>")]

  try
    set selection=inclusive
    let l:select = {"line": "'[V']", "char": "`[v`]", "block": "`[\<c-v>`]"}
    normal! m`
    execute "noautocmd keepjumps normal! \<Esc>" get(l:select, a:type)
    execute 'noautocmd keepjumps %s/\v%V\_.*%V./\=' . a:func . '(submatch(0))'
    execute "noautocmd keepjumps normal! \<Esc>"
    normal! ``
    nohl
  finally
    call setpos("'<", l:visual_marks_save[0])
    call setpos("'>", l:visual_marks_save[1])
    let &selection = l:sel_save
  endtry
endfunction

" Use PercentDecode as includeexpr for selected filetypes to make gf work on local links
let s:filetypes = get(g:, 'percent_filetypes', ['html', 'markdown', 'pandoc'])
let s:filetypes_pattern = join(s:filetypes, "")

augroup percent
  autocmd!
  if s:filetypes_pattern != ""
    execute "autocmd! FileType" s:filetypes_pattern
          \ "setlocal includeexpr=PercentDecode(v:fname)"
  endif
augroup END
