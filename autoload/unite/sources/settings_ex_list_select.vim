let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#settings_ex_list_select#define()
	return s:settings_ex_list_select
endfunction
let s:settings_ex_list_select = {
			\ 'name'        : 'settings_ex_list_select',
			\ 'description' : '•¡”‘I‘ð',
			\ 'syntax'      : 'uniteSource__settings',
			\ 'hooks'       : {},
			\ }
let s:settings_ex_list_select.hooks.on_syntax = function('unite_setting#sub_setting_syntax')
function! s:settings_ex_list_select.hooks.on_init(args, context) "{{{
	if len(a:args) > 0
		let a:context.source__dict_name = a:args[0].dict_name
		let a:context.source__valname_ex   = a:args[0].valname_ex
		let a:context.source__kind      = a:args[0].kind
		let a:context.source__only      = get(a:args[0], 'only_', 0)
	endif
endfunction
"}}}
function! s:settings_ex_list_select.gather_candidates(args, context) "{{{

	let dict_name  = a:context.source__dict_name
	let valname_ex = a:context.source__valname_ex
	let kind       = a:context.source__kind
	let only_      = a:context.source__only

	let datas  = unite_setting_ex2#get_strs_on_off_new(dict_name, valname_ex, kind)

	if only_
		let num_ = 1
	else
		let num_ = 0
		call insert(datas, { 'str' : ' NULL ', 'flg' : 0 })
	endif

	let rtns = []
	for data in datas
		let rtns += [{
					\ 'word'               : num_.' - '.data.str,
					\ 'kind'               : 'settings_ex_list_select',
					\ 'action__dict_name'  : dict_name,
					\ 'action__valname_ex' : valname_ex,
					\ 'action__kind'       : kind,
					\ 'action__valname'    : dict_name."['".valname_ex."']['".kind."']['".num_."']",
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
