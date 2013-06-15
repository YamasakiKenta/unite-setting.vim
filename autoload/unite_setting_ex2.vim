let s:save_cpo = &cpo
set cpo&vim

" 必要 ( 2013/05/18 ) 
function! unite_setting_ex2#get_const_flg(dict_name, valname_ex, kind) "{{{
	let datas = copy(unite_setting_ex2#get_orig(a:dict_name, a:valname_ex, a:kind))

	let flg = 0
	if exists('datas.consts')
		if len(datas.consts)
			let flg = 1
		endif
	endif

	return flg
endfunction
"}}}
function! unite_setting_ex2#set(dict_name, valname_ex, kind, val) "{{{

	if exists(a:dict_name.'["'.a:valname_ex.'"]["'.a:kind.'"]')
		let valname = a:dict_name.'["'.a:valname_ex.'"]["'.a:kind.'"]'
	else
		let valname = a:valname_ex
	endif

	exe 'let '.valname.' = a:val'

	if a:valname_ex =~ '^g:'
		let tmp = unite_setting_ex_3#get(a:dict_name, a:valname_ex)
		exe 'let '.a:valname_ex.' = tmp'
	endif

endfunction
"}}}
function! unite_setting_ex2#get_orig(dict_name, valname_ex, kind) "{{{
	exe 'let tmp_d = '.a:dict_name
	let kind = '__default'

	if exists('tmp_d[a:valname_ex][kind]')
		let rtn = tmp_d[a:valname_ex][kind]
	else
		exe 'let rtn = '.a:valname_ex
	endif

	return rtn

endfunction
"}}}
function! unite_setting_ex2#get_str(val) "{{{
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

	let datas = copy(unite_setting_ex2#get_orig(a:dict_name, a:valname_ex, a:kind))

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
				\ 'str' : ' '.unite_setting_ex2#get_str(v:val).' ',
				\ 'flg' : 0,
				\ }")

	try 
		for num_ in filter(copy(num_flgs), 'v:val >= 0')
			let rtns[num_].str = '<'.unite_setting_ex2#get_str(get(datas.items, num_, '*ERROR')).'>'
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
function! unite_setting_ex2#get_type(dict_name, valname_ex, kind) "{{{

	let type_ = 'title'
	if  exists(a:dict_name.'[a:valname_ex].__type')
		exe 'let type_ = '.a:dict_name.'[a:valname_ex].__type'
	else
		if exists(a:valname_ex)
			exe 'let tmp = '.a:valname_ex
			let type_ = type(tmp)
			if type([]) == type_ || type({}) == type_
				let type_ = 'list'
			elseif type(0) == type_ && ( tmp == 0 || tmp == 1 ) 
				let type_ = 'bool'
			else
				let type_ = 'var'
			endif
		endif
	endif

	retu type_
endfunction
"}}}
function! unite_setting_ex2#get_source_word_sub(dict_name, valname_ex, kind, str) "{{{
	exe 'let tmp_d = '.a:dict_name
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

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
else
	set cpo&
endif
