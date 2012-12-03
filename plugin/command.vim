let s:save_cpo = &cpo
set cpo&vim


let g:unite_setting_default_data = ''
command! -nargs=1 SettingAdd call s:setting_add(<q-args>)
function! s:setting_add(str) "{{{
endfunction
"}}}


let &cpo = s:save_cpo
unlet s:save_cpo

