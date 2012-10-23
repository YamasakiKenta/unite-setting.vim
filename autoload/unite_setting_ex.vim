"sub 
function! s:get_lists(datas) "{{{

	if a:datas[0] < 0
		let rtns = a:datas[1:]
	else
		let rtns = copy(unite_setting#get_nums_form_bit(a:datas[0]*2))

		call filter (rtns, "exists('a:datas[v:val]')")
		call map    (rtns, "a:datas[v:val]")
	endif

	return rtns
endfunction "}}}
"main
function! unite_setting_ex#add(dict_name, valname, description, type, val) "{{{

	exe 'let tmp_d = '.a:dict_name

	if !exists('tmp_d[a:valname]') 
		let tmp_d[a:valname] = {} 
	endi

	let tmp_d[a:valname] = {
				\ '__type'        : a:type,
				\ '__description' : a:description,
				\ '__common'      : a:val,
				\ '__default'     : a:val,
				\ }

	call add(tmp_d.__order, a:valname)

	exe 'let '.a:dict_name.' = tmp_d'

endfunction "}}}
function! unite_setting_ex#get(dict_name, valname, kind) "{{{
	exe 'let tmp_d = '.a:dict_name
	let type_ = tmp_d[a:valname].__type

	" 存在しない場合は、common を代入する
	if !exists('tmp_d[a:valname][a:kind]')
		let a:tmp_d[a:valname][a:kind] = tmp_d[a:valname].__common
	endif

	let val = tmp_d[a:valname][a:kind]

	if type_ == 'list'
		let rtns = s:get_lists(val)
	elseif type_ == 'select'
		let rtns = join(s:get_lists(val))
	else
		let rtns = val
	endif

	return rtns
endfunction "}}}
function! unite_setting_ex#load(dict_name) "{{{
	exe 'let origin_ = '.a:dict_name

	let file_ = origin_.__file

	" 読み込み
	let lists  = readfile( file_ )
	exe 'let tmp_d = '.join(lists)

	" 上書き
	for key in keys(tmp_d)
		let origin_[key] = tmp_d[key]
	endfor

	exe 'let '.a:dict_name.' = tmp_d'
endfunction "}}}
