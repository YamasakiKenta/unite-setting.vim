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
function! s:check_common(dict_name, valname_ex, kind) "{{{
	let tmp_d
	if !exists('tmp_d[a:valname_ex].__common')
		if !exists('tmp_d[a:valname_ex]')
			if exists('valname_ex')
				let tmp_d[a:valname_ex].__common = valname_ex
			else
				let tmp_d[a:valname_ex].__common = 0
			endif
		endif
	endif
endfunction "}}}

function! unite_setting_ex#add(dict_name, valname_ex, description, type, val) "{{{

	let tmp_d = {}
	if exists(a:dict_name)
		exe 'let tmp_d = '.a:dict_name
	endif

	let tmp_d.__order       = get(tmp_d , '__order'    , [])
	let tmp_d[a:valname_ex] = get(tmp_d , a:valname_ex , {})

	let tmp_d[a:valname_ex].__type        = a:type
	let tmp_d[a:valname_ex].__description = a:description
	let tmp_d[a:valname_ex].__default     = a:val
	let tmp_d[a:valname_ex].__common      = get(tmp_d[a:valname_ex], '__common', a:val)

	call add(tmp_d.__order, a:valname_ex)

	exe 'let '.a:dict_name.' = tmp_d'

endfunction "}}}

function! unite_setting_ex#get(dict_name, valname_ex, kind) "{{{
	exe 'let tmp_d = '.a:dict_name

	" š «‘‚É“o˜^‚ª‚È‚¢ê‡ ( ‚Ç‚¤‚µ‚æ‚¤ ) "{{{
	if !exists('tmp_d[a:valname_ex]') 
		if exists(a:valname_ex)
			exe 'return '.a:valname_ex
		else
			return 0
		endif
	endif
	"}}}

	"call s:check_common(a:dict_name, a:valname_ex, a:kind)

	" “o˜^‚ª‚È‚¢ê‡
	if !exists('tmp_d[a:valname_ex][a:kind]')
		let tmp_d[a:valname_ex][a:kind] = tmp_d[a:valname_ex].__common
	endif

	let type_ = tmp_d[a:valname_ex].__type
	let val   = tmp_d[a:valname_ex][a:kind]

	if type_ == 'list_ex'
		let rtns = s:get_lists(val)
	elseif type_ == 'select'
		let rtns = join(s:get_lists(val))
	else
		let rtns = val
	endif

	return rtns
endfunction "}}}

function! unite_setting_ex#load(dict_name, file) "{{{
	let g:tmp_unite_setting = {}
	let file_ = expand(a:file)
	if filereadable(file_)
		exe 'so '.file_
	endif

	let tmp = 0
	for valname in g:tmp_unite_setting.__order
		if valname =~ 'g:'
			unlet tmp 
			let tmp = unite_setting_ex#get('g:tmp_unite_setting', valname, '__common')
			exe 'let '.valname.' = tmp'
		endif
	endfor

	exe 'let '.a:dict_name.' = g:tmp_unite_setting'
	exe 'let '.a:dict_name.'.__file = expand(a:file)'

	unlet g:tmp_unite_setting
endfunction "}}}
