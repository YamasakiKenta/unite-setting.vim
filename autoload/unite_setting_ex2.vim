let s:save_cpo = &cpo
set cpo&vim

" 必要 ( 2013/05/18 ) 
function! unite_setting_ex2#dict(dict_name)
	try
		exe 'return '.a:dict_name
	catch
		echo a:dict_name
		call input("")
		return []
	endtry
endfunction
function! unite_setting_ex2#get_const_flg(dict_name, valname_ex, kind) "{{{
	let datas = copy(unite_setting_ex2#dict(a:dict_name)[a:valname_ex].__default)

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
function! unite_setting_ex2#get_strs_on_off_new(dict_name, valname_ex, kind) "{{{

	let datas = copy(unite_setting_ex2#dict(a:dict_name)[a:valname_ex].__default)

	" ★　バグ対応
	if type(datas) != type({})
		echo 'ERROR ' string(datas)
		unlet datas
		let datas = {'nums' : [], 'items' : [], 'consts' : []}
	endif

	if exists('datas.nums')
		let num_flgs  = datas.nums
	elseif exists('datas.num')
		let num_flgs  = [datas.num]
	else
		let num_flgs = []
	endif

	" ★　バグ対応
	if type(num_flgs) != type([])
		echo 'ERROR ' string(num_flgs)
		unlet num_flgs
		let num_flgs = []
	endif

	let rtns = map(copy(datas.items), "{
				\ 'str' : ' '.s:get_str(v:val).' ',
				\ 'flg' : 0,
				\ }")

	try 
		for num_ in filter(copy(num_flgs), 'v:val >= 0')
			let rtns[num_].str = '<'.s:get_str(get(datas.items, num_, '*ERROR')).'>'
			let rtns[num_].flg = 1
		endfor
	catch
		" ★ 新規追加の場合エラーが発生する
		echo 'ERROR - catch' string(num_) string(rtns)
	endtry


	if !exists('rtns')
		let rtns = [{'str' : '', 'flg' : 0}]
	endif

	return rtns
endfunction
"}}}

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
else
	set cpo&
endif
