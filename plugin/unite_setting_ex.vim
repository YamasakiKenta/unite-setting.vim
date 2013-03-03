let s:save_cpo = &cpo
set cpo&vim

call unite_setting_ex2#init()

let &cpo = s:save_cpo
unlet s:save_cpo
