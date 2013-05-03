let s:save_cpo = &cpo
set cpo&vim

function! unite_setting_ex_3#add(dict_name, valname_ex, description, type, val) "{{{

	let tmp_d = {}
	if exists(a:dict_name)
		exe 'let tmp_d = '.a:dict_name
	endif

	let tmp_d[a:valname_ex] = get(tmp_d , a:valname_ex , {})

	let val = a:val

	" �� �̗p�̕ϊ�
	if a:type =~ 'list_ex\|select' && type(a:val) == type([])
		let val = { 'nums' : map(a:val[0], "v:val-1"), 'items' : a:val[1:] }
	endif

	let tmp_d[a:valname_ex].__type        = a:type
	let tmp_d[a:valname_ex].__description = a:description
	let tmp_d[a:valname_ex].__common      = get(tmp_d[a:valname_ex], '__common', val)


	let tmp_d.__order = get(tmp_d , '__order', [])
	call add(tmp_d.__order, a:valname_ex)

	exe 'let '.a:dict_name.' = tmp_d'

endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
