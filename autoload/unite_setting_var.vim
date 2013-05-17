let s:save_cpo = &cpo
set cpo&vim

let s:valname_to_source_kind_tabel = {
			\ type(0)              : 'kind_settings_common',
			\ type("")             : 'kind_settings_common',
			\ type(function("tr")) : 'kind_settings_common',
			\ type(0.0)            : 'kind_settings_common',
			\ type([])             : 'kind_settings_list',
			\ type({})             : 'kind_settings_list',
			\ }

function! s:get_source_kind(valname) 
	exe 'let Tmp = '.a:valname
	return s:valname_to_source_kind_tabel[type(Tmp)]
endfunction

function! s:get_source_word(valname) 
	exe 'let Tmp = '.a:valname
	return printf("%-100s : %s", a:valname, string(Tmp))
endfunction

function! unite_setting_var#get_valnames(valname) 
	exe 'let Tmp = '.a:valname
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

let unite_setting_var#source_tmpl = {
			\ 'description' : 'show var',
			\ 'syntax'      : 'uniteSource__settings',
			\ 'hooks'       : {},
			\ 'is_quit'     : 0,
			\ }
let unite_setting_var#source_tmpl.hooks.on_syntax = function("unite_setting2#sub_setting_syntax")

function! unite_setting_var#source_tmpl.hooks.on_init(args, context) 
	let a:context.source__valname = get(a:args, 0, 'g:')
endfunction

function! unite_setting_var#source_tmpl.change_candidates(args, context) "{{{

	let new_    = a:context.input
	let valname = a:context.source__valname
	exe 'let type = type('.valname.')'

	if type == type([])
		exe 'let tmps = type('.valname.') ? '.valname.' : []'
		let num_ = len(tmps)
		let valname = valname.'['.num_.']'
	elseif type == type({})
		let valname = valname.'['''.new_.''']'
	endif


	let rtns = []
	if new_ != ''
		let rtns = [{
					\ 'word' : printf("[add]%45s : %s", valname, new_),
					\ 'kind' : 'kind_settings_common',
					\ 'action__valname'   : valname,
					\ 'action__new'   : new_
					\ }]
	endif

	return rtns

endfunction
"}}}

function! unite_setting_var#get_candidate(valnames)
	return map(copy(a:valnames), "{
				\ 'word'              : s:get_source_word(v:val),
				\ 'kind'              : s:get_source_kind(v:val),
				\ 'action__valname'   : v:val,
				\ }")
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
