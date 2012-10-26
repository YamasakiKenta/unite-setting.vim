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
function! unite_setting_ex#get_format(description, type, val) "{{{
	return {
				\ '__type' : a:type, 
				\ '__description' : a:description,
				\ '__default' : a:val,
				\ '__common' : a:val,
				\ }
endfunction "}}}

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
function! unite_setting_ex#add_var(dict_name, valname, description, type) "{{{

	exe 'let tmp_d = '.a:dict_name
	exe 'let data = '.a:valname

	let tmp_d[a:valname] = get(tmp_d, a:valname, {})

	let tmp_d[a:valname].__type        = a:type
	let tmp_d[a:valname].__description = a:description
	let tmp_d[a:valname].__default     = a:val
	let tmp_d[a:valname].__common      = get(tmp_d[a:valname], '__common', data)

	call add(tmp_d.__order, a:valname)

	exe 'let '.a:dict_name.' = tmp_d'

endfunction "}}}
function! unite_setting_ex#get(dict_name, valname, kind) "{{{
	exe 'let tmp_d = '.a:dict_name
	let type_ = tmp_d[a:valname].__type

	" ���݂��Ȃ��ꍇ�́Acommon ��������
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

function! unite_setting_ex#load(dict_name, file) "{{{
	exe 'so '.expand(a:file)
	exe 'let '.a:dict_name.' = g:tmp_unite_setting'
	exe 'let '.a:dict_name.'.__file = expand(a:file)'
endfunction "}}}
