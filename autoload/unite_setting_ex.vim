let s:save_cpo = &cpo
set cpo&vim

let s:Common = vital#of('unite-setting.vim').import('Mind.Common')

function! s:get_lists(datas) "{{{

	let rtns = []

	try
		let max = len(a:datas.items)
		for num_ in filter(a:datas.nums, 'v:val < max')
			call add(rtns, a:datas.items[num_])
		endfor
	catch
		echo 'error s:get_lists'
	endtry

	return rtns
endfunction
"}}}
function! s:get_select_item(datas) "{{{

	let rtn = 0

	" VŒ^
	if exists('a:datas.items[a:datas.num]')
		let rtn = a:datas.items[a:datas.num]
	endif

	return rtn
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

	if type == 'select' || type == 'list_ex'

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

function! unite_setting_ex#init(...) "{{{

	let dict_name = get(a:, 1, 'g:unite_setting_ex_default_data'              )
	let file_name = get(a:, 2, simplify('~/.'.matchstr(dict_name, 'g:\zs.*')) )

	let tmp = {
				\ "__order"  : [],
				\ "__file"   : file_name,
				\ 'set_kind' : {
				\ '__type'   : 'select',
				\ '__common' : { 'items' : ['__default'], 'num' : 0 },
				\ }
				\ }
	exe 'let '.dict_name.' = tmp'

	return dict_name 
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

	" •Ï”‚ÌC³‚ð‚·‚é
	for valname in filter(copy(tmp_d.__order), 'v:val=~"g:"')
		exe 'let '.valname." = unite_setting_ex_3#get(a:dict_name, valname)"
	endfor

	return tmp_d
endfunction
"}}}

function! unite_setting_ex#init2() "{{{
	call unite_setting_ex#init('g:unite_setting_ex_default_data', '~/.unite_setting_ex')
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

