let s:save_cpo = &cpo
set cpo&vim

" 2013/05/25
function! unite_setting#have()
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
