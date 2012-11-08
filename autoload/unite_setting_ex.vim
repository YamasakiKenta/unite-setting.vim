"sub 
function! s:get_lists(datas) "{{{

	let nums = a:datas[0]
	let rtns = []

	let max = len(nums) + 1
	for num_ in nums
		let num_ = num_ < max ? num_ : 1
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

	let tmp_d[a:valname_ex] = get(tmp_d , a:valname_ex , {})

	let tmp_d[a:valname_ex].__type        = a:type
	let tmp_d[a:valname_ex].__description = a:description
	let tmp_d[a:valname_ex].__default     = a:val
	let tmp_d[a:valname_ex].__common      = get(tmp_d[a:valname_ex], '__common', a:val)

	let tmp_d.__order = get(tmp_d , '__order', [])
	let tmp_d[a:valname_ex].__common
	call add(tmp_d.__order, a:valname_ex)

	exe 'let '.a:dict_name.' = tmp_d'

endfunction "}}}
function! unite_setting_ex#add_title(dict_name, valname_ex, title_name) "{{{
 call unite_setting_ex#add( a:dict_name, valname_ex,'perforce clients' , '' , a:title_name)
endfunction "}}}

function! unite_setting_ex#get(dict_name, valname_ex, kind) "{{{
	exe 'let tmp_d = '.a:dict_name

	" š «‘‚É“o˜^‚ª‚È‚¢ê‡ ( ‚Ç‚¤‚µ‚æ‚¤ ) "{{{
	Hhh
		if exists(a:valname_ex)
			exe 'return '.a:valname_ex
		else
			return 0
		endif
	endif
	"}}}

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

function! unite_setting_ex#init(dict_name, file) "{{{
	exe 'let '.a:dict_name.' = {"__order" : [], "__file" : a:file }'
endfunction "}}}
function! unite_setting_ex#load(dict_name, file) "{{{

	let file_ = expand(a:file)
	exe 'let tmp_d = '.a:dict_name
	exe 'so '.file_

	for valname in tmp_d.__order
	echo valname
		let tmp_d[valname] = get(g:tmp_unite_setting, valname, tmp_d[valname])
		if valname =~ 'g:'
			exe 'let '.valname." = unite_setting_ex#get(a:dict_name, valname, '__common')"
		endif
	endfor

	exe 'let '.a:dict_name.' = tmp_d'

	unlet g:tmp_unite_setting
endfunction "}}}
