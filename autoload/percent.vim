" Percent encode a URI, i.e., replace characters with percent codes as required.
"
" Maintainer: Daniel Wennberg
"

function! percent#encode(string) abort
  let l:chars = split(a:string, '\zs')
  return join(map(l:chars, 's:encode_character(v:val)'), "")
endfunction

function! percent#decode(string) abort
  return substitute(a:string, '\v\%(\x\x)', '\=printf("%c", "0x" . submatch(1))', 'g')
endfunction

" -._~ are always permitted. Decimal values: 45, 46, 95, 126
let s:unreserved = '-._~'

function! s:encode_character(char) abort
  " Digits and lower and uppercase ascii letters are always permitted
  let l:decimal = char2nr(a:char)
  if l:decimal >= 48 && l:decimal <= 57  " digits
    return a:char
  elseif l:decimal >= 65 && l:decimal <= 90 " uppercase letters
    return a:char
  elseif l:decimal >= 97 && l:decimal <= 122 " lowercase letters
    return a:char
  elseif a:char =~# '\v[' . s:unreserved . g:percent_permitted . ']'
    return a:char
  endif
  let l:bytes = []
  for l:i in range(strlen(a:char))
    call add(l:bytes, printf("%%%02X", char2nr(strpart(a:char, l:i, 1))))
  endfor
  return join(l:bytes, "")
endfunction

" export pattern matching characters in encoded strings
function! percent#encoded_pattern() abort
  return '[0-9A-Za-z%' . s:unreserved . g:percent_permitted . ']'
endfunction

" Define operator functions that can be mapped to encode/decode text in a buffer
function! percent#encode_op() abort
  set operatorfunc=percent#encode_op_inner
  return 'g@'
endfunction

function! percent#decode_op(...) abort
  set operatorfunc=percent#decode_op_inner
  return 'g@'
endfunction

function! percent#encode_op_inner(type) abort
  return s:substitute_textobj_op(a:type, "percent#encode")
endfunction

function! percent#decode_op_inner(type) abort
  return s:substitute_textobj_op(a:type, "percent#decode")
endfunction

function! s:substitute_textobj_op(type, func) abort
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
