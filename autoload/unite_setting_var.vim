let s:save_cpo = &cpo
set cpo&vim

function! s:get_val(valname)
	exe 'return '.a:valname
endfunction
function! s:get_source_kind(valname) "{{{
	let Tmp = s:get_val(a:valname)
	let valname_to_source_kind_tabel = { 
				\ type(0)              : 'kind_settings_common',
				\ type("")             : 'kind_settings_common',
				\ type(function("tr")) : 'kind_settings_common',
				\ type(0.0)            : 'kind_settings_common',
				\ type([])             : 'kind_settings_list',
				\ type({})             : 'kind_settings_list',
				\ }
	return valname_to_source_kind_tabel[type(Tmp)]
endfunction
"}}}
function! s:get_source_word(valname) "{{{
	let Tmp = s:get_val(a:valname)
	return printf("%s = %s", a:valname, string(Tmp))
endfunction
"}}}
"
function! s:get_valnames_sub_simple(valname) "{{{
	let Tmp = s:get_val(a:valname)
	if a:valname == 'g:'
		let valnames = map(keys(Tmp),
					\ "'g:'.v:val")
	elseif type([]) == type(Tmp)
		let valnames = map(range(len(Tmp)),
					\ "a:valname.'['.v:val.']'")
	elseif type({}) == type(Tmp)
		let valnames = map(keys(Tmp),
					\ "a:valname.'['''.v:val.''']'")
	else
		let valnames = []
	endif

	return valnames
endfunction
"}}}
function! s:get_valnames_sub_all(valname) "{{{
	let valnames = [a:valname]
	let num_     = 0
	while num_ < len(valnames)
		let tmps = s:get_valnames(valnames[num_])

		if len(tmps) > 0
			let valnames = extend(valnames, tmps, num_+1)
			unlet valnames[num_]
		else
			let num_ = num_ + 1
		endif

	endwhile

	return valnames
endfunction
"}}}
function! s:get_valnames(valname, all_flg) "{{{
	if a:all_flg == 1
		let valnames = s:get_valnames_sub_all(a:valname)
	else
		let valnames = s:get_valnames_sub_simple(a:valname)
	endif
	return valnames
endfunction
"}}}

let unite_setting_var#source_tmpl = {
			\ 'description' : 'show var',
			\ 'syntax'      : 'uniteSource__settings',
			\ 'hooks'       : {},
			\ }
function! unite_setting_var#source_tmpl.hooks.on_init(args, context) 
	let a:context.source__valname = get(a:args, 0, 'g:')
endfunction
function! unite_setting_var#source_tmpl.change_candidates(args, context) "{{{
	let new_    = a:context.input
	let valname = a:context.source__valname
	let valdata = s:get_val(valname)
	let type    = type(valdata)

	if type == type([])
		let num_ = len(valdata)
		let valname = valname.'['.num_.']'
	elseif type == type({})
		let valname = valname.'['''.new_.''']'
	endif

	if new_ != ''
		let rtns = [{
					\ 'word'            : printf("[add]%s : ", valname),
					\ 'kind'            : 'kind_settings_common',
					\ 'action__valname' : valname,
					\ 'action__new'     : new_,
					\ }]
	else
		let rtns = []
	endif

	return rtns

endfunction
"}}}
function! unite_setting_var#gather_candidates(args, context, all_flg) "{{{

	let valname  = a:context.source__valname
	let valnames = s:get_valnames(valname, a:all_flg)

	return map(copy(valnames), "{
				\ 'word'              : s:get_source_word(v:val),
				\ 'kind'              : s:get_source_kind(v:val),
				\ 'action__valname'   : v:val,
				\ }")

endfunction
"}}}

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
else
	set cpo&
endif
