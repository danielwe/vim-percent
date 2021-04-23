" Miscellaneous document tagging and wiki linking functionality
"
" Maintainer: Daniel Wennberg
"

" define operator functions that can be mapped to encode/decode text in a buffer
function! percent#op#encode() abort
  set operatorfunc=percent#op#encode_inner
  return 'g@'
endfunction

function! percent#op#decode(...) abort
  set operatorfunc=percent#op#decode_inner
  return 'g@'
endfunction

function! percent#op#encode_inner(type) abort
  return s:substitute_textobj_op(a:type, "percent#encode")
endfunction

function! percent#op#decode_inner(type) abort
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

