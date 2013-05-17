
let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#settings_ex#define()
	return s:settings_ex
endfunction

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
	let dict_name = get(a:context, 'source__dict_name')
	call unite_setting_ex2#save(dict_name)
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
		let orders = unite_setting_ex2#get_valnames(dict_name)
	endif

	" ★ 
	let xind    = '__default'

	" 辞書名と、取得関数が必要になる
	"
	let kind = '__default'
	return map( copy(orders), "{
				\ 'word'               : unite_setting_ex2#get_source_word(dict_name, v:val, kind),
				\ 'kind'               : unite_setting_ex2#get_source_kind(dict_name, v:val, kind),
				\ 'action__kind'       : kind,
				\ 'action__valname'    : unite_setting_ex2#get_source_valname(dict_name, v:val, kind),
				\ 'action__valname_ex' : v:val,
				\ 'action__dict_name'  : dict_name,
				\ 'action__const_flg'  : unite_setting_ex2#get_const_flg(dict_name, v:val, kind),
				\ }")


endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
