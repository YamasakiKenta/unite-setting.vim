let s:save_cpo = &cpo
set cpo&vim
function! unite#sources#settings#define()
	return s:source_settings
endfunction

let s:source_settings = deepcopy(unite_settings#source_tmpl) 
let s:source_settings.name = 'settings'
function! s:source_settings.gather_candidates(args, context) 
	return unite_settings#gather_candidates(a:args, a:context, 0)
endfunction

call unite#define_source(s:source_settings)

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
else
	set cpo&
endif
