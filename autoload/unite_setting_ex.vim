let s:save_cpo = &cpo
set cpo&vim

let s:Common = vital#of('unite-setting.vim').import('Mind.Common')

function! s:get_lists(datas) "{{{

	let rtns = []

	" Åö ãåéÆ
	if type(a:datas) == type([])
		for num_ in filter(a:datas[0], 'v:val < len(a:datas)+1')
			if exists('a:datas[num_]')
				call add(rtns, a:datas[num_])
			endif
		endfor
	else
		" êVå^
		let max = len(a:datas.items)
		for num_ in filter(a:datas.nums, 'v:val < max')
			call add(rtns, a:datas.items[num_])
		endfor
	endif

	return rtns
endfunction
"}}}
function! s:get_kind(valname_ex) "{{{
	exe 'let tmp = '.string(a:valname_ex)
	let _type = type(tmp)

	if _type == type("")
		let setting_type = 'select'
	elseif _type == type([])
		let setting_type = 'list_ex'
	elseif _type == type({})
		let setting_type = 'list'
	elseif _type == type(0)
		if tmp == 0 || tmp == 1
			let setting_type = 'bool'
		else
			let setting_type = 'var'
		endif
	endif

	return setting_type
endfunction
"}}}
function! s:get_var(valname_ex, type) "{{{
	let valname_ex = a:valname_ex
	let type       = a:type
	exe 'let tmp = '.valname_ex

	if type == 'select' || type == 'list_ex'  || type == 'const_select' || type == 'const_list_ex'

		if type(tmp) == type("")
			let tmps = [tmp]
		else
			let tmps = tmp
		endif

		let var = extend([map(range(len(tmps)), 'v:val+1')], tmps)
	else
		let var = tmp
	endif

	return var
endfunction
"}}}

function! unite_setting_ex#get(dict_name, valname_ex, kind) "{{{
	exe 'let tmp_d = '.a:dict_name

	" ìoò^Ç™Ç»Ç¢èÍçá
	if !exists('tmp_d[a:valname_ex][a:kind]')
		let tmp_d[a:valname_ex][a:kind] = tmp_d[a:valname_ex].__common

		" Åö g:Ç∆ÇÃìØä˙
		if exists(a:valname_ex)
			exe 'return '.a:valname_ex
		endif

	endif

	let type_ = tmp_d[a:valname_ex].__type
	let val   = tmp_d[a:valname_ex][a:kind]

	if type_ == 'list_ex' || 'const_list_ex'
		let rtns = s:get_lists(val)
	elseif type_ == 'select' || 'const_select'
		let rtns = join(s:get_lists(val))
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

function! unite_setting_ex#add_title(dict_name, title_name) "{{{
	let valname_ex = 'title_'.a:title_name
	call unite_setting_ex#add( a:dict_name, valname_ex, 'perforce clients' , '' , a:title_name)
endfunction
"}}}

function! unite_setting_ex#init(dict_name, file) "{{{
	exe 'let '.a:dict_name.' = {"__order" : [], "__file" : a:file }'
endfunction
"}}}
function! unite_setting_ex#add(dict_name, valname_ex, description, type, val) "{{{

	let tmp_d = {}
	if exists(a:dict_name)
		exe 'let tmp_d = '.a:dict_name
	endif

	let tmp_d[a:valname_ex] = get(tmp_d , a:valname_ex , {})

	" Åö êÃópÇÃïœä∑
	if a:type =~ 'list_ex\|select' && type(a:val) == type([])
		let val = { 'nums' : map(a:val[0], "v:val-1"), 'items' : a:val[1:] }
	else
		let val = a:val
	endif

	let tmp_d[a:valname_ex].__type        = a:type
	let tmp_d[a:valname_ex].__description = a:description
	let tmp_d[a:valname_ex].__default     = val
	let tmp_d[a:valname_ex].__common      = get(tmp_d[a:valname_ex], '__common', val)


	let tmp_d.__order = get(tmp_d , '__order', [])
	call add(tmp_d.__order, a:valname_ex)

	exe 'let '.a:dict_name.' = tmp_d'

endfunction
"}}}
function! unite_setting_ex#load(dict_name, ...) "{{{

	exe 'let tmp_d = '.a:dict_name
	let file_ = get(tmp_d, '__file', '')
	
	if !filereadable(file_)
		return
	endif

	let load_d = s:Common.load(file_, {})

	let load_d.__file  = file_
	let load_d.__order = tmp_d.__order

	call extend(tmp_d, load_d)

	" ïœêîÇÃèCê≥ÇÇ∑ÇÈ
	for valname in filter(copy(tmp_d.__order), 'v:val=~"g:"')
		exe 'let '.valname." = unite_setting_ex#get(a:dict_name, valname, '__common')"
	endfor

	return tmp_d
endfunction
"}}}

function! unite_setting_ex#init2() "{{{
	call unite_setting_ex#init('g:unite_setting_ex_default_data', '~/.unite_setting_ex')
endfunction
"}}}
function! unite_setting_ex#add2(data_d, ...) "{{{

	if type(a:data_d) == type({})
		" îzóÒÇ…ïœä∑Ç∑ÇÈ
		let data_ds = [a:data_d]
	else
		" ïœêîñºÇÃÇ›ÇÃèÍçá

		let data_ds = []
		let data_d = {}

		" îzóÒÇ…ïœä∑Ç∑ÇÈ
		let valname_exs = extend([a:data_d], a:000)
		for valname_ex in valname_exs
			let  data_d.valname_ex = valname_ex
			call add(data_ds, data_d)
		endfor
	endif

	for data_d in data_ds
		let dict_name     = get(data_d, 'dict_name'    , 'g:unite_setting_ex_default_data' ) 
		let valname_ex    = get(data_d, 'valname_ex'   , '')
		let description   = get(data_d, 'description'  , '')

		exe 'let tmp = '.valname_ex
		let type          = get(data_d, 'type'         , s:get_kind(tmp))
		let val           = get(data_d, 'val'          , s:get_var(valname_ex, type))

		call unite_setting_ex#add(dict_name, valname_ex, description, type, val)
	endfor

endfunction 
"}}}
function! unite_setting_ex#load2() "{{{
	call unite_setting_ex#load('g:unite_setting_ex_default_data')
endfunction
"}}}


let &cpo = s:save_cpo
unlet s:save_cpo

