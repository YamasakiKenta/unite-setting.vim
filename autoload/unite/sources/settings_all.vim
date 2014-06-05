let s:save_cpo = &cpo
set cpo&vim
function! unite#sources#settings_all#define()
	return s:source_settings_all
endfunction

let s:source_settings_all      = deepcopy(unite_settings#source_tmpl) 
let s:source_settings_all.name = 'settings_all'
function! s:source_settings_all.gather_candidates(args, context)
	return unite_settings#gather_candidates(a:args, a:context, 1)
endfunction
"
call unite#define_source(s:source_settings_all)

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
else
	set cpo&
endif
