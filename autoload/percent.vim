" Percent encode a URI, i.e., replace characters with percent codes as required.
"
" Maintainer: Daniel Wennberg
"

function! percent#get(var) abort
  return get(g:, 'percent_' . a:var, g:percent_defaults[a:var])
endfunction

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
  " digits and lower and uppercase ascii letters are always permitted
  let l:decimal = char2nr(a:char)
  if l:decimal >= 48 && l:decimal <= 57  " digits
    return a:char
  elseif l:decimal >= 65 && l:decimal <= 90 " uppercase letters
    return a:char
  elseif l:decimal >= 97 && l:decimal <= 122 " lowercase letters
    return a:char
  elseif a:char =~# '\v[' . s:unreserved . percent#get('permitted') . ']'
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
  return '[0-9A-Za-z%' . s:unreserved . percent#get('permitted') . ']'
endfunction
