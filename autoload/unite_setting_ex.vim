"sub 
function! s:get_lists(datas) "{{{

	let nums = type(a:datas[0]) == type([]) ? 
				\ a:datas[0] : 
				\ unite_setting#get_nums_form_bit(a:datas[0]*2)

	let rtns = []
	for num_ in nums
		" š 
		let num_ = num_ < len(nums) ? num_ : 1
		call add(rtns, a:datas[num_])
	endfor

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

function! unite_setting_ex#load(dict_name, file) "{{{
	exe 'so '.expand(a:file)
	exe 'let '.a:dict_name.' = g:tmp_unite_setting'
	exe 'let '.a:dict_name.'.__file = expand(a:file)'

	" š –³—‚â‚è’uŠ· 
	exe 'let tmp_d = '.a:dict_name

	for tmp in keys(tmp_d)
		if !exists('tmp_d[tmp].__common')
			continue
		endif

		if type(tmp_d[tmp].__common) == type([])
			if type(tmp_d[tmp].__common[0]) != type([])
				let tmp_d[tmp].__common[0] = [1]
			endif
		endif
	endfor

	exe 'let '.a:dict_name.' = tmp_d'

endfunction "}}}
