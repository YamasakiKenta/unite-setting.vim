let unite_setting_ex2#save_cpo = &cpo
set cpo&vim

let unite_setting_ex2#Common = vital#of('unite-setting.vim').import('Mind/Common')
let unite_setting_ex2#Debug = vital#of('unite-setting.vim').import('Mind/Debug')
let s:unite_kind = {
			\ 'bool'     : 'kind_settings_ex_bool',
			\ 'list'     : 'kind_settings_ex_var_list',
			\ 'list_ex'  : 'kind_settings_ex_list',
			\ 'select'   : 'kind_settings_ex_select',
			\ 'var'      : 'kind_settings_ex_var',
			\ }

function! unite_setting_ex2#init()
endfunction

function! unite_setting_ex2#select_list_toggle(candidates) "{{{

	let candidates = type(a:candidates) == type([]) ? a:candidates : [a:candidates]

	let dict_name = candidates[0].action__dict_name
	let valname_ex   = candidates[0].action__valname_ex
	let kind      = candidates[0].action__kind

	let tmps = unite_setting_ex2#get_orig(dict_name, valname_ex, kind)

	let nums = []
	for candidate in candidates
		if ( candidate.action__num > 0 )
			call add(nums, candidate.action__num)
		endif
	endfor

	" 新規追加の場合
	if candidates[0].action__new != ''
		call insert(tmps, candidates[0].action__new, 1)
		call map(nums, "v:val+1")
	else
		call unite#force_quit_session()
	endif

	let tmps[0] = nums
	call unite_setting_ex2#set(dict_name, valname_ex, kind, tmps)

	call unite_setting_ex2#common_out(dict_name)
	return 
endfunction "}}}

function! unite_setting_ex2#cnv_list_ex_select(dict_name, valname_ex, kind, type) "{{{
		let tmp =  unite_setting_ex#get(a:dict_name, a:valname_ex, a:kind) 
		
		if type(tmp) == type([])
			let val = [[1]] + tmp
		else
			let val = [[1], tmp]
		endif

		call unite_setting_ex2#set_type(a:dict_name, a:valname_ex, a:kind, a:type)

		call unite_setting_ex2#set(a:dict_name, a:valname_ex, a:kind, val)
		
endfunction "}}}
let g:test3 = [[1], 'test', 'test2']
function! unite_setting_ex2#save(dict_name) "{{{
	exe 'let tmp_d = '.a:dict_name
	call unite_setting_ex2#Common.save(tmp_d.__file, tmp_d)
endfunction "}}}
function! unite_setting_ex2#delete(dict_name, valname_ex, kind, delete_nums) "{{{

	" 並び替え
	let delete_nums = copy(a:delete_nums)
	call sort(delete_nums, 'unite_setting_ex2#sort_lager')

	" 番号の取得
	let datas = unite_setting_ex2#get_orig(a:dict_name, a:valname_ex, a:kind)

	" 選択番号の削除
	let nums = datas[0]

	" 削除 ( 大きい数字から削除 ) 
	for delete_num in delete_nums
		" 番号の更新
		if exists('datas[delete_num]')
			unlet datas[delete_num]
		endif

		" 削除
		call filter(nums, "v:val != delete_num")
		call map(nums, "v:val - (v:val > delete_num? 1: 0)")
	endfor

	" 選択番号の設定
	let datas[0] = nums

	" 設定
	call unite_setting_ex2#set(a:dict_name, a:valname_ex, a:kind, datas)

endfunction "}}}
function! unite_setting_ex2#get_source_valname(dict_name, valname_ex, kind) "{{{
	if exists(a:valname_ex)
		let valname = a:valname_ex
	else
		let valname = a:dict_name.'['''.a:valname_ex.''']['''.a:kind.''']'
	endif
	return valname
endfunction "}}}
function! unite_setting_ex2#common_out(dict_name) "{{{
	call unite#force_redraw()
endfunction "}}}
function! unite_setting_ex2#get_bits(dict_name, valname_ex, kind) "{{{

	let tmp_d = unite_setting_ex2#get_orig(a:dict_name, a:valname_ex, a:kind)
	let bits  = map(range(len(tmp_d)), "0")

	" ★　バグ対応
	if 0 && type(tmp_d[0]) != type([])
		let tmp_d[0] = [1]
	endif

	for num_ in tmp_d[0]
		let num_ = num_ < len(tmp_d) ? num_ : 1
		let bits[num_] = num_
	endfor


	return bits
endfunction "}}}
function! unite_setting_ex2#get_kind(dict_name, valname_ex, kind) "{{{
	if exists(a:dict_name.'[a:valname_ex][a:kind]')
		return a:kind
	endif
	return '__common'
endfunction "}}}
function! unite_setting_ex2#get_orig(dict_name, valname_ex, kind) "{{{
	exe 'let tmp_d = '.a:dict_name
	let kind = unite_setting_ex2#get_kind(a:dict_name, a:valname_ex, a:kind)

	if exists('tmp_d[a:valname_ex][kind]')
		let rtn = tmp_d[a:valname_ex][kind]
	else
		exe 'let rtn = '.a:valname_ex
	endif

	return rtn

endfunction "}}}
function! unite_setting_ex2#get_source_kind(dict_name, valname_ex, kind) "{{{
	let type = unite_setting_ex2#get_type(a:dict_name, a:valname_ex, a:kind)
	return get( s:unite_kind, type, 'title')
endfunction "}}}
function! unite_setting_ex2#get_source_word(dict_name, valname_ex, kind) "{{{
	exe 'let tmp_d = '.a:dict_name
	let type = unite_setting_ex2#get_type(a:dict_name, a:valname_ex, a:kind)

	if type == 'bool'
		let rtn = unite_setting_ex2#get_source_word_from_bool(a:dict_name, a:valname_ex, a:kind)
	elseif type == 'list_ex' || type == 'select' 
		let rtn = unite_setting_ex2#get_source_word_from_strs(a:dict_name, a:valname_ex, a:kind)
	elseif type == 'var'|| type == 'list'
		let rtn = unite_setting_ex2#get_source_word_from_val(a:dict_name, a:valname_ex, a:kind)
	else
		" ★ タイトルをわける
		let rtn = '"'.a:valname_ex.'"'
	endif

	return printf("%10s %s", type, rtn)
endfunction "}}}
function! unite_setting_ex2#get_source_word_from_bool(dict_name, valname_ex, kind) "{{{
	let str =  unite_setting_ex#get(a:dict_name, a:valname_ex, a:kind) ? 
				\ '<TRUE>  FALSE ' :
				\ ' TRUE  <FALSE>'
	return unite_setting_ex2#get_source_word_sub( a:dict_name, a:valname_ex, a:kind, str)
endfunction "}}}
function! unite_setting_ex2#get_source_word_from_strs(dict_name, valname_ex, kind) "{{{
	let datas = unite_setting_ex2#get_strs_on_off_new(a:dict_name, a:valname_ex, a:kind)
	let strs = map(datas, 'v:val.str')
	return unite_setting_ex2#get_source_word_sub( a:dict_name, a:valname_ex, a:kind, join(strs))
endfunction "}}}
function! unite_setting_ex2#get_source_word_from_val(dict_name, valname_ex, kind) "{{{
	let data = unite_setting_ex#get(a:dict_name, a:valname_ex, a:kind)
	return unite_setting_ex2#get_source_word_sub( a:dict_name, a:valname_ex, a:kind, string(data))
endfunction "}}}
function! unite_setting_ex2#get_source_word_sub(dict_name, valname_ex, kind, str) "{{{
	exe 'let tmp_d = '.a:dict_name
	let description = ''
	if exists('tmp_d[a:valname_ex].__description')
		let description = tmp_d[a:valname_ex].__description
	endif

	return printf(' %-100s %50s - %s', 
				\ description,
				\ unite_setting_ex2#get_source_word_sub_type(a:dict_name, a:valname_ex, a:kind),
				\ a:str,
				\ )
endfunction "}}}
function! unite_setting_ex2#get_source_word_sub_type(dict_name, valname_ex, kind) "{{{
	let kind = unite_setting_ex2#get_kind( a:dict_name, a:valname_ex, a:kind) 

	if exists(a:valname_ex)
		let star = '_'
	elseif kind=='__common'
		let star = '*'
	else
		let star = ' '
	endif

	return star.''.a:valname_ex.''.star
endfunction "}}}
function! unite_setting_ex2#get_str(val) "{{{
	let type_ = type(a:val)
	if type_ == type(0) || type_ == type('a')
		let str = a:val
	else
		let str = string(a:val)
	endif
	return str
endfunction "}}}
function! unite_setting_ex2#get_strs_on_off_new(dict_name, valname_ex, kind) "{{{

	let datas = copy(unite_setting_ex2#get_orig(a:dict_name, a:valname_ex, a:kind))

	" ★　バグ対応
	if type(datas) != type([])
		unlet datas
		let datas = []
	endif

	let num_flgs  = datas[0]

	" ★　バグ対応
	if type(num_flgs) != type([])
		unlet num_flgs
		let num_flgs = []
	endif

	if len(datas) > 0

		let rtns = [0] + map(copy(datas[1:]), "{
					\ 'str' : ' '.unite_setting_ex2#get_str(v:val).' ',
					\ 'flg' : 0,
					\ }")
	endif

	try 
		for num_ in num_flgs
			let rtns[num_].str = '<'.unite_setting_ex2#get_str(get(datas, num_, '*ERROR')).'>'
			let rtns[num_].flg = 1
		endfor
	catch
		" ★ 新規追加の場合エラーが発生する
		echo num_
		echo rtns
	endtry


	if !exists('rtns')
		let rtns = [{'str' : '', 'flg' : 0}]
	endif

	unlet rtns[0]

	return rtns

endfunction "}}}
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
endfunction "}}}
function! unite_setting_ex2#set_type(dict_name, valname_ex, kind, type) "{{{
		exe 'let tmp_d = '.a:dict_name

		if !exists('tmp_d[a:valname_ex]')
			let tmp_d[a:valname_ex] = {}
		endif

		let tmp_d[a:valname_ex].__type = a:type

		if a:type == 'bool'
			let tmp_d[a:valname_ex][a:kind] = s:set_type_bool(tmp_d[a:valname_ex][a:kind])
		endif

		exe 'let '.a:dict_name.' = tmp_d'
endfunction "}}}

function! unite_setting_ex2#set(dict_name, valname_ex, kind, val) "{{{

	if exists(a:dict_name.'["'.a:valname_ex.'"]["'.a:kind.'"]')
		let valname = a:dict_name.'["'.a:valname_ex.'"]["'.a:kind.'"]'
	else
		let valname = a:valname_ex
	endif

	exe 'let '.valname.' = a:val'

	if exists(a:valname_ex) || a:valname_ex =~ '^g:'
		let tmp = unite_setting_ex#get(a:dict_name, a:valname_ex, a:kind)
		exe 'let tmp2 = '.a:valname_ex
		if type(tmp) == type(tmp2)
			exe 'let '.a:valname_ex.' = tmp'
		endif
	endif

endfunction "}}}
function! unite_setting_ex2#set_next(dict_name, valname_ex, kind) "{{{
	exe 'let tmp_d = '.a:dict_name
	let type = unite_setting_ex2#get_type(a:dict_name, a:valname_ex, a:kind)

	if type == 'bool'
		let val = unite_setting_ex#get(a:dict_name, a:valname_ex, a:kind) ? 0 : 1
	else
		let val = unite_setting_ex2#get_orig(a:dict_name, a:valname_ex, a:kind)

		let num_ = val[0][0]
		let num_ = num_ + 1
		let num_ = num_ < len(val) ? num_ : 1

		let val[0][0] = num_

	endif

	call unite_setting_ex2#set(a:dict_name, a:valname_ex, a:kind, val )
endfunction "}}}

function! unite_setting_ex2#get_valnames(valname) "{{{
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
endfunction "}}}

function! s:set_type_bool(val) "{{{
	return type(a:val) == type(0) ? a:val : 0
endfunction
"}}}

let &cpo = unite_setting_ex2#save_cpo
unlet unite_setting_ex2#save_cpo

