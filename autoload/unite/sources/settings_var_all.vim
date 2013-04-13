let s:save_cpo = &cpo
set cpo&vim
function! unite#sources#settings_var_all#define()
	return s:source_settings_var_all
endfunction

let s:source_settings_var_all = deepcopy(unite_setting2#source_tmpl) 
let s:source_settings_var_all.name        = 'settings_var_all'
function! s:source_settings_var_all.gather_candidates(args, context) "{{{

	let valname = a:context.source__valname

	call unite#print_source_message(valname, self.name)

	let num_     = 0
	let valnames = [valname]

	while num_ < len(valnames)
		let tmps = unite_setting2#get_valnames(valnames[num_])

		if len(tmps) > 0
			let valnames = unite_setting2#insert_list(valnames, tmps, num_)
			unlet valnames[num_]
		else
			let num_ = num_ + 1
		endif

	endwhile

	return map(copy(valnames), "{
				\ 'word'              : unite_setting2#get_source_word(v:val),
				\ 'kind'              : unite_setting2#get_source_kind(v:val),
				\ 'action__valname'   : v:val,
				\ }")

endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
