let s:save_cpo = &cpo
set cpo&vim
function! unite#sources#settings_var_all#define()
	return s:source_settings_var_all
endfunction

function! s:insert_list(list1, list2, num_) 
	exe 'let tmps = a:list1[0:'.a:num_.'] + a:list2 + a:list1['.(a:num_+1).':]'
	return tmps
endfunction

let s:source_settings_var_all      = deepcopy(unite_setting_var#source_tmpl) 
let s:source_settings_var_all.name = 'settings_var_all'
function! s:source_settings_var_all.gather_candidates(args, context) "{{{

	let valname = a:context.source__valname

	call unite#print_source_message(valname, self.name)

	let num_     = 0
	let valnames = [valname]

	while num_ < len(valnames)
		let tmps = unite_setting_var#get_valnames(valnames[num_])

		if len(tmps) > 0
			let valnames = s:insert_list(valnames, tmps, num_)
			unlet valnames[num_]
		else
			let num_ = num_ + 1
		endif

	endwhile

	return unite_setting_var#get_candidate(valnames)

endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
