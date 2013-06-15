let s:save_cpo = &cpo
set cpo&vim


function! s:get_val(valname)
	exe 'return '.a:valname
endfunction
function! s:get_source_kind(valname) "{{{
	let tmp = s:get_val(a:valname)
	let valname_to_source_kind_tabel = { 
				\ type(0)              : 'kind_settings_common',
				\ type("")             : 'kind_settings_common',
				\ type(function("tr")) : 'kind_settings_common',
				\ type(0.0)            : 'kind_settings_common',
				\ type([])             : 'kind_settings_list',
				\ type({})             : 'kind_settings_list',
				\ }
	return valname_to_source_kind_tabel[type(tmp)]
endfunction
"}}}
function! s:get_source_word(valname) "{{{
	let tmp = s:get_val(a:valname)
	return printf("%-100s : %s", a:valname, string(tmp))
endfunction
"}}}
function! unite_setting_var#get_valnames(valname) "{{{
	let tmp = s:get_val(a:valname)
	if a:valname == 'g:'
		let valnames = map(keys(tmp),
					\ "'g:'.v:val")
	elseif type([]) == type(tmp)
		let valnames = map(range(len(tmp)),
					\ "a:valname.'['.v:val.']'")
	elseif type({}) == type(tmp)
		let valnames = map(keys(tmp),
					\ "a:valname.'['''.v:val.''']'")
	else
		let valnames = []
	endif

	return valnames
endfunction
"}}}

let unite_setting_var#source_tmpl = {
			\ 'description' : 'show var',
			\ 'syntax'      : 'uniteSource__settings',
			\ 'hooks'       : {},
			\ 'is_quit'     : 0,
			\ }
function! unite_setting_var#source_tmpl.hooks.on_syntax(...)
	return call("unite_setting_2#sub_setting_syntax", a:000)
endfunction

function! unite_setting_var#source_tmpl.hooks.on_init(args, context) 
	let a:context.source__valname = get(a:args, 0, 'g:')
endfunction

function! unite_setting_var#source_tmpl.change_candidates(args, context) "{{{

	" ’Ç‰Á
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


	let rtns = []
	if new_ != ''
		let rtns = [{
					\ 'word'            : printf("[add]%45s : %s", valname, new_),
					\ 'kind'            : 'kind_settings_common',
					\ 'action__valname' : valname,
					\ 'action__new'     : new_,
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

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
else
	set cpo&
endif
