let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#settings_ex#define()
	return s:settings_ex 
endfunction

function! s:get_source_kind(dict_name, valname_ex) "{{{
	let type = unite_setting_ex2#var(a:dict_name)[a:valname_ex].__type
	let unite_kind = {
				\ 'bool'           : 'kind_settings_ex_bool',
				\ 'list'           : 'kind_settings_ex_var_list',
				\ 'select'         : 'kind_settings_ex_select',
				\ 'list_ex'        : 'kind_settings_ex_select',
				\ 'var'            : 'kind_settings_ex_var',
				\ }
	return get( unite_kind, type, 'common')
endfunction
"}}}

function! s:get_source_word_sub(dict_name, valname_ex, kind, str) "{{{
	let tmp_d = unite_setting_ex2#var(a:dict_name)
	let description = ''
	if exists('tmp_d[a:valname_ex].__description')
		let description = tmp_d[a:valname_ex].__description
	endif

	return unite_setting#util#printf(' %-100s %50s - %s', 
				\ description,
				\ a:valname_ex,
				\ a:str,
				\ )
endfunction
"}}}
function! s:get_source_word_from_strs(dict_name, valname_ex, kind) "{{{
	let datas = unite_setting_ex2#get_strs_on_off_new(a:dict_name, a:valname_ex, a:kind)
	let strs  = map(datas, 'v:val.str')
	return s:get_source_word_sub( a:dict_name, a:valname_ex, a:kind, join(strs))
endfunction
"}}}
function! s:get_source_word(dict_name, valname_ex, kind) "{{{

	let type = unite_setting_ex2#var(a:dict_name)[a:valname_ex].__type

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
function! s:get_source_word_from_bool(dict_name, valname_ex, kind) "{{{
	try
		let str =  unite_setting#data#get(a:dict_name, a:valname_ex) ? 
					\ '<TRUE>  FALSE ' :
					\ ' TRUE  <FALSE>'
	catch
		echo a:valname_ex
		call input("")
	endtry
	return s:get_source_word_sub( a:dict_name, a:valname_ex, a:kind, str)
endfunction
"}}}
function! s:get_source_word_from_val(dict_name, valname_ex, kind) "{{{
	let data = unite_setting#data#get(a:dict_name, a:valname_ex)
	return s:get_source_word_sub( a:dict_name, a:valname_ex, a:kind, string(data))
endfunction
"}}}

let s:settings_ex = {
			\ 'name'        : 'settings_ex',
			\ 'description' : '',
			\ 'syntax'      : 'uniteSource__settings',
			\ 'hooks'       : {},
			\ 'is_quit'     : 0,
			\ }
function! s:settings_ex.hooks.on_syntax(...)
	return call('unite_setting_2#sub_setting_syntax', a:000)
endfunction
function! s:settings_ex.hooks.on_init(args, context) "{{{
	if exists('a:args[0]')
		let a:context.source__dict_name = a:args[0]
	else
		let a:context.source__dict_name = unite_setting_ex_3#init()
	endif
endfunction
"}}}
function! s:settings_ex.hooks.on_close(args, context) "{{{
	let tmp_d = unite_setting_ex2#var(a:context.source__dict_name)
	call unite_setting#util#save(tmp_d.__file, tmp_d)
	echo 'save -> '.tmp_d.__file
endfunction
"}}}
function! s:settings_ex.gather_candidates(args, context) "{{{
	let dict_name = a:context.source__dict_name
	call unite#print_source_message(dict_name, self.name)

	if !exists(a:context.source__dict_name)
		call unite#print_error(printf("not find %s.", a:context.source__dict_name))
		return []
	endif

	let tmp_d = unite_setting_ex2#var(dict_name)
	if !exists('tmp_d.__order')
		call unite#print_error(printf('add %s.__order', dict_name))
		return []
	endif

	let kind = '__default'
	return map( copy(tmp_d.__order), "{
				\ 'word'               : s:get_source_word(dict_name, v:val, kind),
				\ 'kind'               : s:get_source_kind(dict_name, v:val),
				\ 'action__kind'       : kind,
				\ 'action__valname'    : printf('%s[\"%s\"][\"%s\"]', dict_name, v:val, kind),
				\ 'action__valname_ex' : v:val,
				\ 'action__dict_name'  : dict_name,
				\ 'action__const_flg'  : unite_setting_ex2#get_const_flg(dict_name, v:val, kind),
				\ }")
endfunction
"}}}

call unite#define_source(s:settings_ex)

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
else
	set cpo&
endif
