let s:save_cpo = &cpo
set cpo&vim

let s:Common = vital#of('unite-setting.vim').import('Mind.Common')

function! s:get_lists(datas) "{{{

	let rtns = []

	for num_ in filter(a:datas[0], 'v:val < len(a:datas)+1')
		call add(rtns, a:datas[num_])
	endfor

	return rtns
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
	call add(tmp_d.__order, a:valname_ex)

	exe 'let '.a:dict_name.' = tmp_d'

endfunction "}}}
function! unite_setting_ex#add_title(dict_name, title_name) "{{{
	let valname_ex = 'title_'.a:title_name
	call unite_setting_ex#add( a:dict_name, valname_ex, 'perforce clients' , '' , a:title_name)
endfunction "}}}
function! unite_setting_ex#get(dict_name, valname_ex, kind) "{{{
	exe 'let tmp_d = '.a:dict_name

	" �o�^���Ȃ��ꍇ
	if !exists('tmp_d[a:valname_ex][a:kind]')
		let tmp_d[a:valname_ex][a:kind] = tmp_d[a:valname_ex].__common

		" �� g:�Ƃ̓���
		if exists(a:valname_ex)
			exe 'return '.a:valname_ex
		endif

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
	return 
endfunction "}}}
function! unite_setting_ex#load(dict_name, file) "{{{

	let file_ = expand(a:file)
	exe 'let tmp_d = '.a:dict_name
	
	if !filereadable(file_)
		return
	endif

	let load_d = s:Common.load(file_, {})

	let load_d.__file  = file_
	let load_d.__order = tmp_d.__order

	call extend(tmp_d, load_d)

	" �ϐ��̏C��������
	for valname in filter(copy(tmp_d.__order), 'v:val=~"g:"')
		exe 'let '.valname." = unite_setting_ex#get(a:dict_name, valname, '__common')"
	endfor

	return tmp_d
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

