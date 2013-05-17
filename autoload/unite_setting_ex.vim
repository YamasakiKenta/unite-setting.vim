let s:save_cpo = &cpo
set cpo&vim

function! unite_setting_ex#init(...) 
	return call('unite_setting_ex_3#init', a:000)
endfunction

function! unite_setting_ex#load(...) 
	return call('unite_setting_ex_3#load', a:000)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

