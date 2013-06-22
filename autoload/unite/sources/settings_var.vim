let s:save_cpo = &cpo
set cpo&vim
function! unite#sources#settings_var#define()
	return s:source_settings_var
endfunction

let s:source_settings_var = deepcopy(unite_setting_var#source_tmpl) 
let s:source_settings_var.name = 'settings_var'
function! s:source_settings_var.gather_candidates(args, context) 
	return unite_setting_var#gather_candidates(a:args, a:context, 0)
endfunction

call unite#define_source(s:source_settings_var)

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
else
	set cpo&
endif
