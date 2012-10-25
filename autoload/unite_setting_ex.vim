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

	let tmp_d[a:valname] = get(tmp_d, a:valname, {})

	let tmp_d[a:valname].__type        = a:type
	let tmp_d[a:valname].__description = a:description
	let tmp_d[a:valname].__default     = a:val
	let tmp_d[a:valname].__common      = get(tmp_d[a:valname], '__common', a:val)

	call add(tmp_d.__order, a:valname)

	exe 'let '.a:dict_name.' = tmp_d'

endfunction "}}}
function! unite_setting_ex#get(dict_name, valname, kind) "{{{
	exe 'let tmp_d = '.a:dict_name
	let type_ = tmp_d[a:valname].__type

	" ‘¶İ‚µ‚È‚¢ê‡‚ÍAcommon ‚ğ‘ã“ü‚·‚é
	if !exists('tmp_d[a:valname][a:kind]')
		let tmp_d[a:valname][a:kind] = tmp_d[a:valname].__common
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

	exe 'let data_d = 'a:dict_name

	exe 'so '.expand(data_d.__file)

	for data in filter(keys(data_d), "v:val =~ '^__'")
		exe 'let '.a:dict_name.'[data] = data_d[data]'
	endfor

endfunction "}}}
