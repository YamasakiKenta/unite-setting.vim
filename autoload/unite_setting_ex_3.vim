let s:save_cpo = &cpo
set cpo&vim

let s:default = 'g:unite_setting_ex_default_data'

function! s:get_kind(dict_name, valname_ex) "{{{
	" ********************************************************************************
	" @par 種別を取得する
	" ********************************************************************************
	
	let dict_name = ( a:dict_name == '' ? s:default : a:dict_name ) 

	let num  = 0
	let kind = '__default'

	if exists(dict_name)
		exe 'let tmp = '.dict_name

		if exists('tmp.set_kind.__type.__common.num')
			let num = tmp.set_kind.__type.__common.num
		endif

		if exists('tmp.set_kind.__type.__common.items[num]')
			let kind = tmp.set_kind.__type.__common.items[num]	
		endif
	endif

	return kind
endfunction
"}}}
function! s:get_lists(datas) "{{{


	try
		let rtns = []
		let max = len(a:datas.items)
		for num_ in filter(a:datas.nums, 'v:val < max')
			call add(rtns, a:datas.items[num_])
		endfor
		return rtns

	catch
		echo 's:get_lists -> ERROR'
		return []

	endtry

endfunction
"}}}
function! s:get_select_item(datas) "{{{

	let rtn = 0

	" 新型
	if exists('a:datas.items[a:datas.num]')
		let rtn = a:datas.items[a:datas.num]
	endif

	return rtn
endfunction
"}}}

function! unite_setting_ex_3#add_with_type(dict_name, valname_ex, description, val, type) "{{{

	let dict_name = ( a:dict_name == '' ? s:default : a:dict_name ) 

	let tmp_d = {}
	if exists(dict_name)
		exe 'let tmp_d = '.dict_name
	endif

	let tmp_d[a:valname_ex] = get(tmp_d, a:valname_ex, {})
	let tmp_d[a:valname_ex].__type        = a:type
	let tmp_d[a:valname_ex].__description = a:description
	let tmp_d[a:valname_ex].__default     = get(tmp_d[a:valname_ex], '__default', a:val)

	let tmp_d.__order = get(tmp_d , '__order', [])

	" 重複させない
	let set_flg = 1
	for data in tmp_d.__order 
		if data == a:valname_ex
			let set_flg = 0
		endif
	endfor
	if set_flg == 1
		call add(tmp_d.__order, a:valname_ex)
	endif

	exe 'let '.dict_name.' = tmp_d'

	if a:valname_ex =~ '^g:'
		let tmp = unite_setting_ex_3#get(dict_name, a:valname_ex)
		exe 'let '.a:valname_ex.' = tmp'
	endif

endfunction
"}}}
function! unite_setting_ex_3#add(dict_name, valname_ex, description, val) "{{{

	let val_type_ = type(a:val)

	let type_ = 'var'
	if type(0) ==  val_type_
		let type_ = 'bool'
	elseif type([]) == val_type_
		let type_ = 'list'
	elseif type({}) == val_type_
		let type_ = 'list' 
		if type(get(a:val, 'num', [])) == type(0)
			let type_ = 'select'
		elseif type(get(a:val, 'nums', 0)) == type([])
			let type_ = 'list_ex'
		endif
	endif

	return unite_setting_ex_3#add_with_type(a:dict_name, a:valname_ex, a:description, a:val, type_) 

endfunction
"}}}
function! unite_setting_ex_3#add_val(dict_name, valname_ex) "{{{
	" ********************************************************************************
	" @par 変数で辞書に追加できる
	" @param[in]      = <`2`>
	" @return        <`3`> = <`4`>
	" ********************************************************************************
	
	let new_flg = 0

	if !exists(a:valname_ex)
		let new_flg = 1
		exe 'let '.a:valname_ex.' = ""'

	endif

	exe 'let val_data = '.a:valname_ex

	let val_type_ = type(val_data)

	if new_flg == 1
		let type_ = 'var'
		let val   = ''
	elseif type(0) == val_type_ || type('') == val_type_
		if val_data == 0 || val_data == 1
			let type_ = 'bool'
			let val   = val_data
		else
			let type_ = 'select'
			let val   = { 'num' : 0, 'items' : [val_data] }
		endif
	elseif type([]) == val_type_
		let tmp = type(val_data[0])
		if type(0) == tmp || type('') == tmp
			let tmp_nums = range(len(val_data))

			let type_ = 'select'
			let val   = { 'nums' : tmp_nums, 'items' : val_data }
		else
			let type_ = 'list'
			let val   = val_data
		endif
	elseif type({}) == val_type_
		let type_ = 'list'
		let val   = val_data
	else
		let type_ = 'var'
		let val   = val_data
	endif
	
	return unite_setting_ex_3#add_with_type(a:dict_name, a:valname_ex, '', val, type_)

endfunction
"}}}

function! unite_setting_ex_3#get(dict_name, valname_ex) "{{{

	let dict_name = ( a:dict_name == '' ? s:default : a:dict_name ) 

	" 値の取得
	exe 'let tmp_d = '.dict_name

	" kind の設定
	let kind = s:get_kind(dict_name, a:valname_ex)
	if exists('tmp_d[a:valname_ex].__common')
		let kind = __common
	elseif !exists('tmp_d[a:valname_ex][kind]')
		let tmp_d[a:valname_ex][kind] = tmp_d[a:valname_ex].__default
	endif

	let type_ = tmp_d[a:valname_ex].__type
	let val   = tmp_d[a:valname_ex][kind]

	if type_ == 'list_ex' 
		let rtns = s:get_lists(val)
	elseif type_ == 'select'
		let rtns = s:get_select_item(val)
	elseif type_ == 'bool'
		try
			let rtns = val > 0 ? 1 : 0
		catch
			let rtns = 0
		endtry
	else
		let rtns = val
	endif

	return rtns
endfunction
"}}}

function! unite_setting_ex_3#init(...) "{{{

	let dict_name = ( get(a:, 1, '') == '' ? s:default : a:1 ) 
	let file_name = get(a:, 2, expand('~/.'.matchstr(dict_name, 'g:\zs.*')) )

	if !exists(dict_name)
		echo 'unite_setting_ex_3#init -> init'
		let tmp = {
					\ "__order"  : [],
					\ "__file"   : file_name,
					\ 'set_kind' : {
					\ '__type'   : 'select',
					\ '__common' : { 'items' : ['__default'], 'num' : 0 },
					\ }
					\ }
		exe 'let '.dict_name.' = tmp'

		call call('unite_setting_ex_3#load', a:000)
	else
	endif

	return dict_name 
endfunction
"}}}
function! unite_setting_ex_3#load(...) "{{{


	let dict_name = get(a:, 1, s:default )

	exe 'let tmp_d = '.dict_name
	let file_ = get(tmp_d, '__file', '')

	
	if !filereadable(file_)
		echo 'unite_setting_ex_3#load -> not find '.file_
		return
	else
		echo 'unite_setting_ex_3#load -> find file'
	endif

	let load_d = unite_setting#util#load(file_, {})


	let load_d.__file  = file_

	" Add 後、データだけ読み出したい場合の為
	if len(tmp_d.__order)
		let load_d.__order = tmp_d.__order
	endif

	call extend(tmp_d, load_d)

	" ★ ADD の時点でも行うが、ファイルで取得した値を入れる
	" 変数の修正をする
	for valname in filter(copy(tmp_d.__order), 'v:val=~"g:"')
		exe 'let '.valname." = unite_setting_ex_3#get(dict_name, valname)"
	endfor

	return tmp_d
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
