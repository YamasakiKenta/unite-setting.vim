"sub 
function! s:get_lists(datas) "{{{

	if a:datas[0] < 0
		let rtns = a:datas[1:]
	else
		let rtns = copy(s:get_nums_form_bit(a:datas[0]*2))

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
	endif

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

	" ‘¶İ‚µ‚È‚¢ê‡‚ÍAcommon ‚ğ‘ã“ü‚·‚é
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
