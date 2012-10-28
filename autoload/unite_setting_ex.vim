"sub 
function! s:get_lists(datas) "{{{

	if type(a:datas[0]) == type([])
		let nums = a:datas[0]
	else
		" š
		let nums = unite_setting#get_nums_form_bit(a:datas[0]*2)
	endif

	let rtns = []
	for num_ in nums
		let num_ = num_ < len(a:datas[0]) ? num_ : 1
		call add(rtns, a:datas[num_])
	endfor

	return rtns
endfunction "}}}
"main
function! unite_setting_ex#add(dict_name, valname_ex, description, type, val) "{{{

	exe 'let tmp_d = '.a:dict_name

	let tmp_d[a:valname_ex] = get(tmp_d, a:valname_ex, {})

	let tmp_d[a:valname_ex].__type        = a:type
	let tmp_d[a:valname_ex].__description = a:description
	let tmp_d[a:valname_ex].__default     = a:val
	let tmp_d[a:valname_ex].__common      = get(tmp_d[a:valname_ex], '__common', a:val)

	call add(tmp_d.__order, a:valname_ex)

	exe 'let '.a:dict_name.' = tmp_d'

endfunction "}}}

function! unite_setting_ex#get(dict_name, valname_ex, kind) "{{{
	exe 'let tmp_d = '.a:dict_name
	let type_ = tmp_d[a:valname_ex].__type

	" ‘¶İ‚µ‚È‚¢ê‡‚ÍAcommon ‚ğ‘ã“ü‚·‚é
	if !exists('tmp_d[a:valname_ex][a:kind]')
		let tmp_d[a:valname_ex][a:kind] = tmp_d[a:valname_ex].__common
	endif

	let val = tmp_d[a:valname_ex][a:kind]

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
