let s:save_cpo = &cpo
set cpo&vim

command! -nargs=1 AddUniteSetting call unite_setting_ex_3#add_val('', <q-args>)

let &cpo = s:save_cpo
unlet s:save_cpo
