if 0
let s:valname_to_source_kind_tabel = {
			\ type(0)              : 'settings_ex_var',
			\ type("")             : 'settings_ex_var',
			\ type(function("tr")) : 'settings_ex_var',
			\ type(0.0)            : 'settings_ex_var',
			\ type([])             : 'settings_ex_vars',
			\ type({})             : 'settings_ex_vars',
			\ }

function! s:get_source_var_word(valname, data) "{{{
	return printf("%-50s : %s", a:valname, string(a:data))
endfunction "}}}
function! s:get_source_var_kind(valname, data) "{{{
	exe 'let tmp = '.a:valname
	return s:valname_to_source_kind_tabel[type(a:data)]
endfunction "}}}

" s:kind_settings_ex_vars  "{{{
let s:kind = { 
			\ 'name'           : 'settings_ex_vars',
			\ 'default_action' : 'select',
			\ 'action_table'   : {},
			\ }
let s:kind.action_table.select = {
			\ 'description' : 'ê›íËï“èW',
			\ 'is_quit'     : 0,
			\ }"
function! s:kind.action_table.select.func(candidate) "{{{
	let dict_name = a:candidate.action__dict_name
	let valname   = a:candidate.action__valname
	let kind      = a:candidate.action__kind

	call unite_setting_ex#get(dict_name, valname, kind)

	echo a:candidate
	let valname = dict_name.'['''.valname.''']['''.kind.''']'

	call unite#start_temporary([['settings_var', valname]])
endfunction "}}}
let s:kind_settings_ex_vars = deepcopy(s:kind)
"}}}
"s:source_settings_ex_var "{{{
let s:source = {
			\ 'name'        : 'settings_ex_var',
			\ 'description' : 'show var',
			\ 'syntax'      : 'uniteSource__settings',
			\ 'hooks'       : {},
			\ 'is_quit'     : 0,
			\ }
let s:source.hooks.on_syntax = function("unite_setting#sub_setting_syntax")
function! s:source.hooks.on_init(args, context) "{{{
	if len(a:args) > 0
		let a:context.source__dict_name = a:args[0].dict_name
		let a:context.source__valname   = a:args[0].valname
		let a:context.source__kind      = a:args[0].kind
	endif
endfunction "}}}
function! s:source.gather_candidates(args, context) "{{{

	" ê›íËÇ∑ÇÈçÄñ⁄
	let dict_name = a:context.source__dict_name
	let valname   = a:context.source__valname
	let kind      = a:context.source__kind

	let tmp = type(unite_setting_ex#get(a:dict_name, a:valname, a:kind))

	if type([]) == type(tmp)
		let vars = map(range(len(tmp)), "
					\ 'valname' : valname.'['.v:val.']',
					\ 'data'    : tmp[v:val],
					\ ")
	elseif type({}) == type(tmp)
		let vars = map(keys(tmp), "
					\ 'valname' : valname.'['''.v:val.''']',
					\ 'data'    : tmp[v:val],
					\ ")
	endif

	return map( copy(vars), "{
				\ 'word'              : s:get_source_var_word(v:val.valname, v:val.data),
				\ 'kind'              : s:get_source_var_kind(v:val.valname, v:val.data),
				\ 'action__valname'   : valname,
				\ }")

endfunction "}}}
let s:source_settings_ex_var = deepcopy(s:source)
"}}}
"
call unite#define_kind   ( s:kind_settings_ex_vars          )  | unlet s:kind_settings_ex_vars
call unite#define_source ( s:source_settings_ex_var         )  | unlet s:source_settings_ex_var
endif
