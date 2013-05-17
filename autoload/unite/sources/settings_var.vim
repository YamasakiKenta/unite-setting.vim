let s:save_cpo = &cpo
set cpo&vim
function! unite#sources#settings_var#define()
	return s:source_settings_var
endfunction
let s:source_settings_var = deepcopy(unite_setting_var#source_tmpl) 
let s:source_settings_var.name        = 'settings_var'
function! s:source_settings_var.gather_candidates(args, context) "{{{

	let valname = a:context.source__valname

	call unite#print_source_message(valname, self.name)

	let valnames = unite_setting_var#get_valnames(valname)

	return unite_setting_var#get_candidate(valnames)

endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
