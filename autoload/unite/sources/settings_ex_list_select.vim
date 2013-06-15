let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#settings_ex_list_select#define()
	return s:settings_ex_list_select
endfunction
let s:settings_ex_list_select = {
			\ 'name'        : 'settings_ex_list_select',
			\ 'description' : '複数選択',
			\ 'syntax'      : 'uniteSource__settings',
			\ 'hooks'       : {},
			\ }
function! s:settings_ex_list_select.hooks.on_syntax(...)
	return call('unite_setting_2#sub_setting_syntax', a:000)
endfunction
function! s:settings_ex_list_select.hooks.on_init(args, context) "{{{
	if len(a:args) > 0
		let a:context.source__dict_name    = a:args[0].dict_name
		let a:context.source__valname_ex   = a:args[0].valname_ex
		let a:context.source__kind         = a:args[0].kind
		let a:context.source__const        = get(a:args[0], 'const_', 0)
	endif
endfunction
"}}}
function! s:settings_ex_list_select.gather_candidates(args, context) "{{{

	let dict_name  = a:context.source__dict_name
	let valname_ex = a:context.source__valname_ex
	let kind       = a:context.source__kind
	let const_     = a:context.source__const

	let datas  = unite_setting_ex2#get_strs_on_off_new(dict_name, valname_ex, kind)

	let type = unite_setting_ex2#var(dict_name)[valname_ex].__type
	let only_ = ( type == 'select' ? 1 : 0 )

	if only_ == 1 
		" select
		let num_ = 0
		let unite_kind = 'settings_ex_list_select'
	else
		" list
		" 非選択用の項目
		let num_ = -1
		let unite_kind = 'settings_ex_list_selects'
		call insert(datas, { 'str' : ' NULL ', 'flg' : 0 })
	endif

	let rtns = []
	for data in datas
		" 変化するのは、work action__num, action__valname
		let rtns += [{
					\ 'word'               : num_.' - '.data.str,
					\ 'kind'               : unite_kind,
					\ 'action__dict_name'  : dict_name,
					\ 'action__valname_ex' : valname_ex,
					\ 'action__kind'       : kind,
					\ 'action__const_flg'  : const_,
					\ 'action__valname'    : dict_name."['".valname_ex."']['".kind."']['items']['".num_."']",
					\ 'action__num'        : num_,
					\ 'action__new'        : '',
					\ }]
					"\ 'unite__is_marked'   : data.flg,
					"\ 'unite__marked_time' : localtime(),
		let num_ += 1
	endfor	

	return rtns

endfunction
"}}}
function! s:settings_ex_list_select.change_candidates(args, context) "{{{

	let new_ = a:context.input
	let dict_name   = a:context.source__dict_name
	let valname_ex     = a:context.source__valname_ex
	let kind        = a:context.source__kind

	let rtns = []
	if new_ != ''
		let rtns = [{
					\ 'word' : '[add] '.new_,
					\ 'kind' : 'settings_ex_list_select',
					\ 'action__new'       : new_,
					\ 'action__dict_name' : a:context.source__dict_name,
					\ 'action__valname_ex'   : a:context.source__valname_ex,
					\ 'action__kind'      : a:context.source__kind,
					\ 'action__num'       : 1,
					\ }]
	endif

	return rtns

endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
