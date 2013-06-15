let s:save_cpo = &cpo
set cpo&vim

" �K�v ( 2013/05/18 ) 
function! unite_setting_ex2#dict(dict_name) "{{{
	try
		exe 'return '.a:dict_name
	catch
		echo a:dict_name
		call input("")
		return []
	endtry
endfunction
"}}}
function! unite_setting_ex2#get_const_flg(dict_name, valname_ex, kind) "{{{
	let datas = unite_setting_ex2#dict(a:dict_name)[a:valname_ex].__default

	let flg = 0
	if exists('datas.consts')
		if len(datas.consts)
			let flg = 1
		endif
	endif

	return flg
endfunction
"}}}
function! s:get_str(val) "{{{
	let type_ = type(a:val)
	if type_ == type(0) || type_ == type('')
		let str = a:val
	else
		let str = string(a:val)
	endif
	return str
endfunction
"}}}
function! s:get_num_flgs(datas) "{{{
	if exists('a:datas.nums')
		let num_flgs  = a:datas.nums
	elseif exists('a:datas.num')
		let num_flgs  = [a:datas.num]
	else
		let num_flgs = []
	endif
	return num_flgs
endfunction
"}}}
function! unite_setting_ex2#get_strs_on_off_new(dict_name, valname_ex) "{{{
	let datas    = copy(unite_setting_ex2#dict(a:dict_name)[a:valname_ex].__default)
	let num_flgs = s:get_num_flgs(datas)

	let rtns = map(copy(datas.items), "{
				\ 'str' : ' '.s:get_str(v:val).' ',
				\ 'flg' : 0,
				\ }")

	let tmp_var = ''
	for num_ in filter(copy(num_flgs), 'v:val >= 0')
		unlet tmp_var
		let tmp_var = get(datas.items, num_, '*ERROR*')
		let rtns[num_].str = '<'.s:get_str(tmp_var).'>'
		let rtns[num_].flg = 1
	endfor

	return rtns
endfunction
"}}}

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
else
	set cpo&
endif
