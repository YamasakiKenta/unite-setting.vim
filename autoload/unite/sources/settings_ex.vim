let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#settings_ex#define()
	return s:settings_ex 
endfunction

function! s:get_valnames(valname) "{{{
	exe 'let tmp = '.a:valname
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
function! s:get_source_kind(dict_name, valname_ex, kind) "{{{
	let type = unite_setting_ex2#get_type(a:dict_name, a:valname_ex, a:kind)
	let unite_kind = {
				\ 'bool'           : 'kind_settings_ex_bool',
				\ 'list'           : 'kind_settings_ex_var_list',
				\ 'select'         : 'kind_settings_ex_select',
				\ 'list_ex'        : 'kind_settings_ex_select',
				\ 'var'            : 'kind_settings_ex_var',
				\ }
	return get( unite_kind, type, 'k_title')
endfunction
"}}}

function! s:get_source_word_from_strs(dict_name, valname_ex, kind) "{{{
	let datas = unite_setting_ex2#get_strs_on_off_new(a:dict_name, a:valname_ex, a:kind)
	let strs  = map(datas, 'v:val.str')
	return unite_setting_ex2#get_source_word_sub( a:dict_name, a:valname_ex, a:kind, join(strs))
endfunction
"}}}
function! s:get_source_word(dict_name, valname_ex, kind) "{{{

	exe 'let tmp_d = '.a:dict_name
	let type = unite_setting_ex2#get_type(a:dict_name, a:valname_ex, a:kind)

	if type == 'bool'
		let rtn = s:get_source_word_from_bool(a:dict_name, a:valname_ex, a:kind)
	elseif type == 'list_ex' || type == 'select' 
		let rtn = s:get_source_word_from_strs(a:dict_name, a:valname_ex, a:kind)
	elseif type == 'var'|| type == 'list'
		let rtn = s:get_source_word_from_val(a:dict_name, a:valname_ex, a:kind)
	else
		let rtn = '"'.a:valname_ex.'"'
	endif

	return unite_setting#util#printf("%10s %s", type, rtn)
endfunction
"}}}
function! s:get_source_valname(dict_name, valname_ex, kind) "{{{
	if exists(a:valname_ex)
		let valname = a:valname_ex
	else
		let valname = a:dict_name.'['''.a:valname_ex.''']['''.a:kind.''']'
	endif
	return valname
endfunction
"}}}
function! s:get_source_word_from_bool(dict_name, valname_ex, kind) "{{{
	let str =  unite_setting_ex_3#get(a:dict_name, a:valname_ex) ? 
				\ '<TRUE>  FALSE ' :
				\ ' TRUE  <FALSE>'
	return unite_setting_ex2#get_source_word_sub( a:dict_name, a:valname_ex, a:kind, str)
endfunction
"}}}
function! s:get_source_word_from_val(dict_name, valname_ex, kind) "{{{
	let data = unite_setting_ex_3#get(a:dict_name, a:valname_ex)
	return unite_setting_ex2#get_source_word_sub( a:dict_name, a:valname_ex, a:kind, string(data))
endfunction
"}}}

let s:settings_ex = {
			\ 'name'        : 'settings_ex',
			\ 'description' : '',
			\ 'syntax'      : 'uniteSource__settings',
			\ 'hooks'       : {},
			\ 'is_quit'     : 0,
			\ }
let s:settings_ex.hooks.on_syntax = function("unite_setting2#sub_setting_syntax")
function! s:settings_ex.hooks.on_init(args, context) "{{{
	if exists('a:args[0]')
		let a:context.source__dict_name = a:args[0]
	else
		let a:context.source__dict_name = unite_setting_ex_3#init()
	endif
endfunction
"}}}
function! s:settings_ex.hooks.on_close(args, context) "{{{
	echo 'save'
	exe 'let tmp_d = '.get(a:context, 'source__dict_name')
	call unite_setting#util#save(tmp_d.__file, tmp_d)
endfunction
"}}}
function! s:settings_ex.gather_candidates(args, context) "{{{
	" 設定する項目
	let dict_name = a:context.source__dict_name
	exe 'let tmp_d = '.dict_name

	call unite#print_source_message(dict_name, self.name)

	" ★ データに登録がない場合は、どうしよう
	if exists('tmp_d.__order')
		let orders  = tmp_d.__order
	else
		let orders = s:get_valnames(dict_name)
	endif

	" ★ 
	let xind    = '__default'

	" 辞書名と、取得関数が必要になる
	"
	let kind = '__default'
	return map( copy(orders), "{
				\ 'word'               : s:get_source_word(dict_name, v:val, kind),
				\ 'kind'               : s:get_source_kind(dict_name, v:val, kind),
				\ 'action__kind'       : kind,
				\ 'action__valname'    : s:get_source_valname(dict_name, v:val, kind),
				\ 'action__valname_ex' : v:val,
				\ 'action__dict_name'  : dict_name,
				\ 'action__const_flg'  : unite_setting_ex2#get_const_flg(dict_name, v:val, kind),
				\ }")


endfunction
"}}}


let &cpo = s:save_cpo
unlet s:save_cpo
