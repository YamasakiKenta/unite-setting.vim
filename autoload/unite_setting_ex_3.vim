let s:save_cpo = &cpo
set cpo&vim

let s:L = vital#of('unite-setting.vim')
let s:Common = s:L.import('Mind.Common')

function! s:get_kind(dict_name, valname_ex) "{{{
	" ********************************************************************************
	" @par 種別を取得する
	" ********************************************************************************

	let num  = 0
	let kind = '__default'

	if exists(a:dict_name)
		exe 'let tmp = '.a:dict_name

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
		echo 'error s:get_lists'
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

function! unite_setting_ex_3#add(dict_name, valname_ex, description, type, val) "{{{

	let val = a:val
	let val_type_ = type(val)

	let type_ = 'var'
	if type(0) ==  val_type_
		let type_ = 'bool'
	elseif type([]) == val_type_
		let type_ = 'list'
	elseif type({}) == val_type_
		let type_ = 'list' 
		if type(get(val, 'num', [])) == type(0)
			let type_ = 'select'
		elseif type(get(val, 'nums', 0)) == type([])
			let type_ = 'list_ex'
		endif
	endif

	let tmp_d = {}
	if exists(a:dict_name)
		exe 'let tmp_d = '.a:dict_name
	endif

	let tmp_d[a:valname_ex] = get(tmp_d, a:valname_ex, {})
	let tmp_d[a:valname_ex].__type        = type_
	let tmp_d[a:valname_ex].__description = a:description
	let tmp_d[a:valname_ex].__default     = get(tmp_d[a:valname_ex], '__default', val)

	let tmp_d.__order = get(tmp_d , '__order', [])
	call add(tmp_d.__order, a:valname_ex)

	exe 'let '.a:dict_name.' = tmp_d'

	if a:valname_ex =~ '^g:'
		let tmp = unite_setting_ex_3#get(a:dict_name, a:valname_ex)
		exe 'let '.a:valname_ex.' = tmp'
	endif


endfunction
"}}}
function! unite_setting_ex_3#get(dict_name, valname_ex) "{{{
	" 値の取得
	exe 'let tmp_d = '.a:dict_name

	" kind の設定
	let kind = s:get_kind(a:dict_name, a:valname_ex)
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
"
function! unite_setting_ex_3#init(...) "{{{

	let dict_name = get(a:, 1, 'g:unite_setting_ex_default_data'              )
	let file_name = get(a:, 2, simplify('~/.'.matchstr(dict_name, 'g:\zs.*')) )

	let tmp = {
				\ "__order"  : [],
				\ "__file"   : file_name,
				\ 'set_kind' : {
				\ '__type'   : 'select',
				\ '__common' : { 'items' : ['__default'], 'num' : 0 },
				\ }
				\ }
	exe 'let '.dict_name.' = tmp'

	return dict_name 
endfunction
"}}}
function! unite_setting_ex_3#load(...) "{{{

	let dict_name = get(a:, 1, 'g:unite_setting_ex_default_data'              )

	exe 'let tmp_d = '.dict_name
	let file_ = get(tmp_d, '__file', '')
	
	if !filereadable(file_)
		return
	endif

	let load_d = s:Common.load(file_, {})

	let load_d.__file  = file_
	let load_d.__order = tmp_d.__order

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
