let s:save_cpo = &cpo
set cpo&vim

command! -nargs=+ SettingExAdd call s:setting_ex_add(<f-args>)

function! s:setting_ex_add(...)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
